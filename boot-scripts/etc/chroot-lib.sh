#
# $Id: chroot-lib.sh,v 1.5 2007-12-07 16:39:59 reiner Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH, 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
#****h* comoonics-bootimage/stdfs-lib.sh
#  NAME
#    chroot-lib.sh
#    $id$
#  DESCRIPTION
#    Library of methods needed to create and manage chroot environments
#    This library is also used to create initrd environments
#*******

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

#****f* chroot-lib.sh/extract_installed_rpm
#  NAME
#    extract_installed_rpm
#  SYNOPSIS
#    function extract_installed_rpm(rpmfile, root, filter) {
#  DESCRIPTION
#    Extracts the found file from rpm rpmfile to the given root
#    If a filter is given only files that match the filter will be copied
#    filter also implies that an expensive -a option is added
#  IDEAS
#    Run rpm -ql rpmfile and copy all listed files to root.
#  SOURCE
#
function extract_installed_rpm() {
  local rpm=$1
  local dest=$2
  local filter=$3
  local qopt=""
  rpm -q $rpm >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Cannot find rpm \"$rpm\". Skipping." >&2
    return 1
  fi

  if [ -n "$filter" ]; then
  	qopt="-a"
  fi
  pushd $dest >/dev/null
  for file in $(rpm -ql $qopt $rpm | grep -e "$filter"); do
  	#echo "rpm : $rpm, $file" >&2
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

#****f* chroot-lib.sh/get_filelist_from_installed_rpm
#  NAME
#    get_filelist_from_installed_rpm
#  SYNOPSIS
#    function get_filelist_from_installed_rpm(rpmfile, filter) {
#  DESCRIPTION
#    returns a filelist from rpmfile
#    If a filter is given only files that match the filter will be given
#    filter also implies that an expensive -a option is added
#  IDEAS
#  SOURCE
#
function get_filelist_from_installed_rpm() {
  local rpm=$1
  local filter=$2
  local qopt=""
  rpm -q $rpm >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Cannot find rpm \"$rpm\". Skipping." >&2
    return 1
  fi

  if [ -n "$filter" ]; then
  	qopt="-a"
  fi
  #for filename in $(rpm -ql $qopt $rpm | grep -e "$filter"); do
  # get all rpms that match filter without docs
  for filename in $(rpm -q $qopt $rpm --dump | grep -e "$filter" | awk ' $9~0 {print $1}'); do
  	echo $filename
  	get_dependent_files $filename
  done
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
  local -a rpmdef
  local rpm
  if [ ! -e "$rpm_listfile" ]; then
    echo "Cannot find rpmlistfile \"$rpm_listfile\". Exiting." >&2
    return 1
  fi

  get_all_rpms_dependent $rpm_listfile $verbose | while read line; do
  	rpmdef=( $line )
  	rpm=${rpmdef[0]}
	filter=${rpmdef[1]}
    if [ ${rpm:0:1} != '#' ]; then
      if [ -f $rpm ]; then
        extract_rpm $rpm $root
      else
      	[ -n "$verbose" ] && echo "$rpm with filter $filter"
        extract_installed_rpm $rpm $root $filter
      fi
    fi
  done
}
#************ extract_all_rpms

#****f* chroot-lib.sh/get_filelist_from_rpms
#  NAME
#    get_filelist_from_rpms
#  SYNOPSIS
#    get_filelist_from_rpms(rpm_listfile, [verbose]) {
#  DESCRIPTION
#    Calls extract_rpm/extract_installed for all files listed in
#    rpm_listfile
#  IDEAS
#  SOURCE
#
function get_filelist_from_rpms() {
  local rpm_listfile=$1
  local verbose=$2
  local -a rpmdef
  local rpm
  if [ ! -e "$rpm_listfile" ]; then
    echo "Cannot find rpmlistfile \"$rpm_listfile\". Exiting." >&2
    return 1
  fi

  get_all_rpms_dependent $rpm_listfile $verbose | while read line; do
  	rpmdef=( $line )
  	rpm=${rpmdef[0]}
	filter=${rpmdef[1]}
    if [ ${rpm:0:1} != '#' ]; then
      [ -n "$verbose" ] && echo "$rpm with filter $filter" >&2
      get_filelist_from_installed_rpm $rpm $filter
    fi
  done
}
#************ get_filelist_from_rpms



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

##****f* chroot-lib.sh/get_dependent_files
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
  filename=$1
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

#****f* chroot-lib.sh/get_all_depfiles
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

#****f* chroot-lib.sh/get_all_files_dependent
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
	# FIXME:
	#   if [ "${line:0:1}" != '#' ]; then does not work. Don't know WHY the shit!!
	#
	if [ -n "${line:0:1}" ]; then
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
          aline=( $(echo $line | tr '&' ' ') )
	      mapdir=${aline[2]}
          line=${aline[1]}
          [ -n "$verbose" ] && echo "Mapping $line to $mapdir" >&2
	      local filename=`which $line 2>/dev/null`
	      if [ -z $filename ]; then
	        filename=$line
  	      fi
	      echo "@map&$filename&$mapdir"
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
    fi
  done <$filename
}
#************ get_all_files_dependent


