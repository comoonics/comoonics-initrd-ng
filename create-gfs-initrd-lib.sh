#
# $Id: create-gfs-initrd-lib.sh,v 1.5 2006-02-03 12:39:27 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#

function create_dir() {
  local dirname=$1
  if [ ! -e $dirname ]; then 
    # echo "creating dir $dirname"; 
    mkdir -p $dirname; 
  fi
}

# copy the file like a dump one.
function copy_file() {
  local filename=$1
  local dest=$2
#  [ -n "$verbose" ] && echo "copying $filename to ${dest}..."
#  if [ -d $dest ] && [ ! -d $filename ]; then
#    dest="$dest/"$(basename $filename)
#  fi
#  if [ ! -e $dest ] || [ $(stat -c%Y $dest) -lt $(stat -c%Y $source) ]; then
    cp -af $filename ${dest}
#  fi
}

# Compile perlfile with perlcc to binary
function perlcc_file() {
  local filename=$1
  local destfile=$2
  [ -z "$destfile" ] && destfile=$filename
  echo "compiling(perlcc) $filename to ${destfile}..." >&2
  olddir=pwd
  cd $(dirname $destfile)
  perlcc $filename && mv a.out $destfile
}

# extract rpm
# param: $1 rpm-name
#        $2 dest
function extract_rpm() {
	 local rpm=$1
	 local dest=$2
	 cd $dest
	 rpm2cpio $1 | cpio -ivdum
	 cd -
}

# extract all rpm in file
# param: $1: file
#        $2: root
function extract_all_rpms() {
	 local rpms=`cat $1`
	 local root=$2
	 for rpm in $rpms; do
    if [ ${rpm:0:1} != '#' ]; then
		  extract_rpm $rpm $root
    fi
  done
}

# 
# checks if the file is executable.
# If so it returns all dependent libraries with path as a stringlist.
function get_dependent_files() {
  local filename=$1
  # file is a symbolic link
  if [ -L $filename ]; then
    local newfile=`ls -l $filename | sed -e "s/.* -> //"`
    if [ "${newfile:0:1}" != "/" ]; then
       echo `dirname $filename`/$newfile
    else
       echo $newfile
    fi
  # file is executable and not directory
  elif [ -x $filename -a ! -d $filename ]; then
    ldd $filename > /dev/null 2>&1
    if [ $? = 0 ]; then
#      local newfiles=`ldd $filename | sed -e "s/^.*=> \(.*\) (.*).*$/\1/" | sed -e "s/^.*statically linked.*$//"`
	local newfiles=`ldd $filename | sed -e "s/\(.*\) (.*)/\1/" | sed -e "s/.* => //" | sed -e "s/\t*//" | grep -v "statically linked"`
      for newfile in $newfiles; do
         echo $newfile
         if [ -L $newfile ]; then
           local _newfile=`ls -l $newfile | sed -e "s/.* -> //"`
           if [ "${_newfile:0:1}" != "/" ]; then
             echo `dirname $newfile`/$_newfile
           else
             echo $_newfile
           fi
         fi
      done
    fi
  fi
}

#
# Get all depfiles gets all depfiles from the given file
# That means if there is a @include tag those files are also returned
function get_all_depfiles {
  local $basefile=$1;
  local $verbose=$2;

  echo $basefile
  for sub_dep_file in $(grep "^@include" $basefile | awk '{print $2;}'); do
    [ -e "$sub_dep_file" ] && get_all_depfiles $sub_dep_file $verbose
  done
}

#
# Takes a filename as argument and pipes all files listed in this file to 
# get_dependent_files.
function get_all_files_dependent() {
  local filename=$1
  local verbose=$2

  while read line; do
    if [ ${line:0:1} != '#' ]; then
      if [ ! -e "$line" ] && [ "${line:0:7}" = '@perlcc' ]; then
        # take next as filename and compile
	echo "Skipping line $todir..." >&2
	line=${line:8}
	local filename=`which $line 2>/dev/null`
	if [ -z $filename ]; then
	  filename=$line
	fi
	#echo $filename
	[ -n "$verbose" ] && echo "Taking perl file $filename..." >&2
	dirname=`dirname $filename`
	create_dir ${mountpoint}$dirname
	perlcc_file $filename ${mountpoint}$filename
	get_dependent_files ${mountpoint}$filename
      elif [ ! -e "$line" ] && [ "${line:0:4}" = '@map' ]; then
        declare -a aline
        aline=( $(echo $line) )
	mapdir=${aline[2]}
        line=${aline[1]}
        [ -n "$verbose" ] && echo "Mapping $line to $mapdir" >&2
	local filename=`which $line 2>/dev/null`
	if [ -z $filename ]; then
	  filename=$line
	fi
	echo "@map $filename $mapdir"
	get_dependent_files $filename
      else
	local filename=`which $line 2>/dev/null`
	if [ -z $filename ]; then
	  filename=$line
	fi
	echo $filename
	get_dependent_files $filename
      fi
    fi
  done <$filename
}

#
# Creates a new memory filesystem initrd with the given size
function make_initrd() {
  local filename=$1
  local size=$2
  dd if=/dev/zero of=$filename bs=1k count=$size > /dev/null 2>&1 && \
  mkfs.ext2 -F -m 0 -i 2000 $filename > /dev/null 2>&1
}

#
# Mounts the given unpacked filesystem to the given directory
function mount_initrd() {
  local filename=$1
  local mountpoint=$2
  mount -o loop -t ext2 $filename $mountpoint > /dev/null 2>&1
}

#
# Unmounts the given loopback memory filesystem and zips it to the given file
function umount_and_zip_initrd() {
  local mountpoint=$1
  local filename=$2
  local force=$3
  local opts=""
  local LODEV=$(mount | grep "^$mountpoint" | tail -1 | cut -f6 -d" " | cut -d"=" -f2)
  LODEV=$(echo ${LODEV/%\)/})
  [ -n "$force" ] && [ $force -gt 0 ] && opts="-f"
  (umount $mountpoint && \
  gzip $opts -9 $filename && losetup -d $LODEV) || (fuser "$mountpoint" && exit 1)
}

#
# Creates an imagefile with cpio and compresses it with zip
function cpio_and_zip_initrd() {
  local mountpoint=$1
  local filename=$2
  local force=$3
  local opts=""
  [ -n "$force" ] && [ $force -gt 0 ] && opts="-f"
  ((cd $mountpoint; find . | cpio --quiet -c -o) >| $filename && gzip $opts -9 $filename)|| (fuser -mv "$mountpoint" && exit 1)
}
