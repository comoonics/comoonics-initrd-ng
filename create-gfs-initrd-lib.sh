#****h* comoonics-bootimage/create-gfs-initrd-lib.sh
#  NAME
#    create-gfs-initrd-lib.sh
#    $id$
#  DESCRIPTION
#    Library for the creating of initrds for sharedroot
#*******
#
# $Id: create-gfs-initrd-lib.sh,v 1.6 2006-05-03 12:46:45 marc Exp $
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

#****f* create-gfs-initrd-lib.sh/create_dir
#  NAME
#    create_dir
#  SYNOPSIS
#    function create_dir() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function create_dir() {
  local dirname=$1
  if [ ! -e $dirname ]; then 
    # echo "creating dir $dirname"; 
    mkdir -p $dirname; 
  fi
}

# copy the file like a dump one.
#************ create_dir 
#****f* create-gfs-initrd-lib.sh/copy_file
#  NAME
#    copy_file
#  SYNOPSIS
#    function copy_file() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ copy_file 
#****f* create-gfs-initrd-lib.sh/perlcc_file
#  NAME
#    perlcc_file
#  SYNOPSIS
#    function perlcc_file() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ perlcc_file 
#****f* create-gfs-initrd-lib.sh/extract_rpm
#  NAME
#    extract_rpm
#  SYNOPSIS
#    function extract_rpm() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ extract_rpm 
#****f* create-gfs-initrd-lib.sh/extract_all_rpms
#  NAME
#    extract_all_rpms
#  SYNOPSIS
#    function extract_all_rpms() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ extract_all_rpms 
#****f* create-gfs-initrd-lib.sh/get_dependent_files
#  NAME
#    get_dependent_files
#  SYNOPSIS
#    function get_dependent_files() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ get_dependent_files 
#****f* create-gfs-initrd-lib.sh/get_all_depfiles
#  NAME
#    get_all_depfiles
#  SYNOPSIS
#    function get_all_depfiles {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ get_all_depfiles 
#****f* create-gfs-initrd-lib.sh/get_all_files_dependent
#  NAME
#    get_all_files_dependent
#  SYNOPSIS
#    function get_all_files_dependent() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ get_all_files_dependent 
#****f* create-gfs-initrd-lib.sh/make_initrd
#  NAME
#    make_initrd
#  SYNOPSIS
#    function make_initrd() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function make_initrd() {
  local filename=$1
  local size=$2
  dd if=/dev/zero of=$filename bs=1k count=$size > /dev/null 2>&1 && \
  mkfs.ext2 -F -m 0 -i 2000 $filename > /dev/null 2>&1
}

#
# Mounts the given unpacked filesystem to the given directory
#************ make_initrd 
#****f* create-gfs-initrd-lib.sh/mount_initrd
#  NAME
#    mount_initrd
#  SYNOPSIS
#    function mount_initrd() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function mount_initrd() {
  local filename=$1
  local mountpoint=$2
  mount -o loop -t ext2 $filename $mountpoint > /dev/null 2>&1
}

#
# Unmounts the given loopback memory filesystem and zips it to the given file
#************ mount_initrd 
#****f* create-gfs-initrd-lib.sh/umount_and_zip_initrd
#  NAME
#    umount_and_zip_initrd
#  SYNOPSIS
#    function umount_and_zip_initrd() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ umount_and_zip_initrd 
#****f* create-gfs-initrd-lib.sh/cpio_and_zip_initrd
#  NAME
#    cpio_and_zip_initrd
#  SYNOPSIS
#    function cpio_and_zip_initrd() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function cpio_and_zip_initrd() {
  local mountpoint=$1
  local filename=$2
  local force=$3
  local opts=""
  [ -n "$force" ] && [ $force -gt 0 ] && opts="-f"
  ((cd $mountpoint; find . | cpio --quiet -c -o) >| $filename && gzip $opts -9 $filename)|| (fuser -mv "$mountpoint" && exit 1)
}
#************ cpio_and_zip_initrd 

######################
# $Log: create-gfs-initrd-lib.sh,v $
# Revision 1.6  2006-05-03 12:46:45  marc
# added documentation
#
