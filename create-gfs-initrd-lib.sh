#****h* comoonics-bootimage/create-gfs-initrd-lib.sh
#  NAME
#    create-gfs-initrd-lib.sh
#    $id$
#  DESCRIPTION
#    Library for the creating of initrds for sharedroot
#*******
#
# $Id: create-gfs-initrd-lib.sh,v 1.10 2007-02-09 11:09:31 marc Exp $
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
#
#************ create_dir

#****f* create-gfs-initrd-lib.sh/copy_file
#  NAME
#    copy_file
#  SYNOPSIS
#    function copy_file() {
#  DESCRIPTION
#    copy the file like a dump one.
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
#************ copy_file

#****f* create-gfs-initrd-lib.sh/perlcc_file
#  NAME
#    perlcc_file
#  SYNOPSIS
#    function perlcc_file(perlfile, destfile) {
#  DESCRIPTION
#    Compiles the perlfile to a binary in destfile
#  IDEAS
#    To be used if special perlfiles are needed without puting all
#    perl things into the initrd.
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
#************ perlcc_file

#****f* create-gfs-initrd-lib.sh/extract_rpm
#  NAME
#    extract_rpm
#  SYNOPSIS
#    function extract_rpm(rpmfile, root) {
#  DESCRIPTION
#    Extracts the given rpmfile to the given root
#  IDEAS
#  SOURCE
#
function extract_rpm() {
	 local rpm=$1
	 local dest=$2
	 (cd $dest &&
	  rpm2cpio $rpm | cpio -ivdum)
}
#************ extract_rpm

#****f* create-gfs-initrd-lib.sh/extract_installed_rpm
#  NAME
#    extract_installed_rpm
#  SYNOPSIS
#    function extract_installed_rpm(rpmfile, root) {
#  DESCRIPTION
#    Extracts the found file from rpm rpmfile to the given root
#  IDEAS
#    Run rpm -ql rpmfile and copy all listed files to root.
#  SOURCE
#
function extract_installed_rpm() {
  local rpm=$1
  local dest=$2
  local verbose=$3
  rpm -q $rpm >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Cannot find rpm \"$rpm\". Skipping." >&2
    return 1
  fi
  pushd $dest >/dev/null
  for file in $(rpm -ql $rpm); do
    [ ! -e ${dest}$(dirname $file) ] && mkdir -p ${dest}$(dirname $file)
    if [ -d $file ]; then
      mkdir ${dest}$file 2>/dev/null
    else
      cp -a $file ${dest}$(dirname $file)
    fi
  done
  popd >/dev/null
}
#************ extract_installed_rpm

#****f* create-gfs-initrd-lib.sh/extract_all_rpms
#  NAME
#    extract_all_rpms
#  SYNOPSIS
#    function extract_all_rpms(rpm_listfile, root, rpmdir) {
#  DESCRIPTION
#    Calls extract_rpm/extract_installed for all files listed in
#    rpm_listfile
#  IDEAS
#  SOURCE
#
function extract_all_rpms() {
  local rpm_listfile=$1
  local root=$2
  local verbose=$3
  if [ ! -e "$rpm_listfile" ]; then
    echo "Cannot find rpmlistfile \"$rpm_listfile\". Exiting." >&2
    return 1
  fi
  rpms=$(get_all_rpms_dependent $rpm_listfile $verbose)

  for rpm in $rpms; do
    if [ ${rpm:0:1} != '#' ]; then
      if [ -f $rpm ]; then
        extract_rpm $rpm $root
      else
        extract_installed_rpm $rpm $root $verbose
      fi
    fi
  done
}
#************ extract_all_rpms

#****f* create-gfs-initrd-lib.sh/get_all_rpms_dependent
#  NAME
#    get_all_rpms_dependent
#  SYNOPSIS
#    function get_all_rpms_dependent() {
#  MODIFICATION HISTORY
#  DOCUMENTATION
#    Takes a filename as argument and pipes all files listed in this file to
#    get_dependent_files.
#  SOURCE
#
function get_all_rpms_dependent {
  local filename=$1
  local verbose=$2
  while read line; do
    if [ -n "$line" ] && [ ${line:0:1} != '#' ]; then
      if [ ! -e "$line" ] && [ "${line:0:8}" = '@include' ]; then
        declare -a aline
        aline=( $(echo $line) )
	    include=${aline[@]:1}
	    if [ -d "$include" ]; then
	      for file in ${include}/*; do
	        [ -n "$verbose" ] && echo "Including rpm $file" >&2
            get_all_rpms_dependent $file $verbose
          done
        elif [ -e "$include" ]; then
	      get_all_rpms_dependent $include $verbose
	    else
          if [ "${include:0:2}" = '$(' ] || [ "${include:0:1}" = '`' ]; then
	        [ -n "$verbose" ] && echo "Eval $include"  >&2
	        include=$(echo ${include/#\$\(/})
	        include=$(echo ${include/#\`/})
	        include=$(echo ${include/%\)/})
	        files=$(eval "$include")
          else
            files="$include"
	      fi
          for file in $files; do
  	        [ -n "$verbose" ] && echo "Including rpm $file" >&2
            get_all_rpms_dependent $file $verbose
          done
        fi
      else
        [ -n "$verbose" ] && echo "rpm $line" >&2
        echo $line
      fi
    fi
  done <$filename
}
#************get_all_rpms_dependent


##****f* create-gfs-initrd-lib.sh/get_dependent_files
#  NAME
#    get_dependent_files
#  SYNOPSIS
#    function get_dependent_files(filename) {
#  DESCRIPTION
#    checks if the file is executable.
#    If so it returns all dependent libraries with path as a stringlist.
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
      local newfiles=$(ldd $filename | awk '
$3 ~ /^\// { print $3; }
$1 ~ /^\// && $3 == "" { print $1; }
')
      for newfile in $newfiles; do
         echo $newfile
         if [ -L $newfile ]; then
           local _newfile=$(ls -l $newfile | awk '$11 != "" { print $11; }')
           if [ "${_newfile:0:1}" != "/" ]; then
             echo $(dirname $newfile)/$_newfile
           else
             echo $_newfile
           fi
         fi
      done
    fi
  fi
}
#************ get_dependent_files

#****f* create-gfs-initrd-lib.sh/get_all_depfiles
#  NAME
#    get_all_depfiles
#  SYNOPSIS
#    function get_all_depfiles {
#  DEPRECATED
#  DESCRIPTION
#   Get all depfiles gets all depfiles from the given file
#   That means if there is a @include tag those files are also returned
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
#************ get_all_depfiles

#****f* create-gfs-initrd-lib.sh/get_all_files_dependent
#  NAME
#    get_all_files_dependent
#  SYNOPSIS
#    function get_all_files_dependent() {
#  MODIFICATION HISTORY
#  DOCUMENTATION
#    Takes a filename as argument and pipes all files listed in this file to
#    get_dependent_files.
#  SOURCE
#
function get_all_files_dependent() {
  local filename=$1
  local verbose=$2
  local line=""
  local dirname=""
  local files=""

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
        # get_dependent_files $filename
      elif [ ! -e "$line" ] && [ "${line:0:8}" = '@include' ]; then
        declare -a aline
        aline=( $(echo $line) )
	    include=${aline[@]:1}
	    if [ -d "$include" ]; then
	      for file in ${include}/*; do
	        [ -n "$verbose" ] && echo "Including file $file" >&2
            get_all_files_dependent $file $verbose
          done
        elif [ -e "$include" ]; then
	      get_all_files_dependent $include $verbose
	    else
          if [ "${include:0:2}" = '$(' ] || [ "${include:0:1}" = '`' ]; then
	        [ -n "$verbose" ] && echo "Eval $include"  >&2
	        include=$(echo ${include/#\$\(/})
	        include=$(echo ${include/#\`/})
	        include=$(echo ${include/%\)/})
	        files=$(eval "$include")
          else
            files="$include"
	      fi
          for file in $files; do
  	        [ -n "$verbose" ] && echo "Including file $file" >&2
            get_all_files_dependent $file $verbose
          done
        fi
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
#************ get_all_files_dependent

#****f* create-gfs-initrd-lib.sh/make_initrd
#  NAME
#    make_initrd
#  SYNOPSIS
#    function make_initrd() {
#  DESCRIPTION
#    Creates a new memory filesystem initrd with the given size
#  IDEAS
#  SOURCE
#
function make_initrd() {
  local filename=$1
  local size=$2
  dd if=/dev/zero of=$filename bs=1k count=$size > /dev/null 2>&1 && \
  mkfs.ext2 -F -m 0 -i 2000 $filename > /dev/null 2>&1
}
#************ make_initrd

#****f* create-gfs-initrd-lib.sh/mount_initrd
#  NAME
#    mount_initrd
#  SYNOPSIS
#    function mount_initrd() {
#  DESCRIPTION
#    Mounts the given unpacked filesystem to the given directory
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
   losetup -d $LODEV && \
   mv $filename ${filename}.tmp && \
   gzip $opts -c -9 ${filename}.tmp > $filename && rm ${filename}.tmp) || (fuser -mv "$mountpoint" && exit 1)
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
  ((cd $mountpoint; find . | cpio --quiet -c -o) >| ${filename}.tmp && gzip $opts -c -9 ${filename}.tmp > $filename && rm ${filename}.tmp)|| (fuser -mv "$mountpoint" && exit 1)
}
#************ cpio_and_zip_initrd

######################
# $Log: create-gfs-initrd-lib.sh,v $
# Revision 1.10  2007-02-09 11:09:31  marc
# cosmetic changes.
#
# Revision 1.9  2006/08/28 16:01:57  marc
# support for rpm-lists and includes of new lists
#
# Revision 1.8  2006/06/19 15:55:28  marc
# rewriten and debuged parts of generating deps. Added @include tag for depfiles.
#
# Revision 1.7  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.6  2006/05/03 12:46:45  marc
# added documentation
#
