#
# $Id: stdfs-lib.sh,v 1.6 2009-10-08 08:00:05 marc Exp $
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
#    stdfs-lib.sh
#    $id$
#  DESCRIPTION
#    Library for std filesystem operations
#*******

#****f* boot-lib.sh/is_modified
#  NAME
#    is_modified
#  SYNOPSIS
#    function is_modified(sourcefile, destfile)
#  DESCRIPTION
#    returns 1 if sourcefile is older or equal to destfile. Otherwise it returns 0
#  IDEAS
#  SOURCE
#
function is_modified {
  local source=$1
  local dest=$2
  if [ -e "$STAT" ]; then
    local smodified=$($STAT -c%Y $source 2>/dev/null)
    local dmodified=$($STAT -c%Y $dest 2>/dev/null)
    if [ -z "$dmodified" ] || [ -z "$smodified" ] || [ $smodified -gt $dmodified ]; then
      return 0
    else
      return 1
    fi
  else
    return 0
  fi
}
#*********** is_modified

#****f* boot-lib.sh/is_same_inode
#  NAME
#    is_same_inode
#  SYNOPSIS
#    function is_same_inode(sourcefile, destfile)
#  DESCRIPTION
#    returns 0 if sourcefile and destfile are the same inode. Otherwise it returns 0
#  IDEAS
#  SOURCE
#
function is_same_inode {
  local source=$1
  local dest=$2
  local lsopt=""
  if [ -d "$source" ]; then
  	lsopt="-d"
  fi
  local sinode=$(/bin/ls $lsopt -i $source | awk '{print $1}')
  if [ -d "$dest" ]; then
  	lsopt="-d"
  else
  	lsopt=""
  fi
  local dinode=$(/bin/ls $lsopt -i $dest | awk '{print $1}')
  if [ $dinode -eq $sinode ]; then
  	return 0
  else
  	return 1
  fi

}
#*********** is_same_inode



#****f* stdfs-lib.sh/create_dir
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

#****f* std-lib.sh/copy_file
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
    cp -auf $filename ${dest}
#  fi
}
#************ copy_file

#****f* boot-lib.sh/cp_file
#  NAME
#    cp_file
#  SYNOPSIS
#    function cp_file(sourcefile, destfile)
#  DESCRIPTION
#    File copy function to copy a file from sourcefile to destfile. Knows about directory.
#    When stat is available it only copys if file is modified.
#  IDEAS
#  SOURCE
#
function cp_file {
  local source=$1
  local dest=$2
  [ -d $(dirname $dest) ] || $MKDIR -p $(dirname $dest) 2>/dev/null
  if [ -d $source ]; then
    if [ ! -e $dest ]; then
      mkdir -p ${dest}
    fi
    sfiles=( $(find $source -maxdepth 1) )
    for sfile in ${sfiles[@]:1}; do
      cp_file $sfile "${dest}/"$(basename $sfile)
    done
  else
    is_modified $source $dest
    if [ $? -eq 0 ]; then
      $COPY -af $source $dest 2>/dev/null
    fi
  fi
}
#************ cp_file




#****f* std-lib.sh/copy_filelist
#  NAME
#    copy_filelist
#  SYNOPSIS
#    function copy_file( destdir, file1, ...) {
#  DESCRIPTION
#    copy al list of files to destdir.
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function copy_filelist() {
	destdir=$1
	shift
	if ! [ -d "$destdir" ]; then
		echo "$destdir is not a directory"
		exit 1
	fi	
	local -a files=( $* )
	i=0
	while [ $i -lt ${#files[@]} ]; do
		file=${files[$i]}
		#copy directories
  		if [ -d $file ]; then
    		echo_local_debug "Directory $file => ${destdir}/$file"
    		create_dir ${destdir}/$file
    		copy_file $file ${destdir}/$(dirname $file)
  		#copy @map srcfile dest
  		elif [ ! -e "$file" ] && [ "$file" = '@map' ]; then
    		i=$(( $i+1 ))
    		file=${files[$i]}
    		i=$(( $i+1 ))
    		todir=${files[$i]}
    		if [ -d $file ]; then
      			echo_local_debug "Directory mapping $file => ${destdir}/$todir"
      			create_dir ${destdir}/$todir
      			for file2 in $(ls -1 $file/*); do
         			copy_file $file/\* ${destdir}/$todir/
      			done
    		else
      			echo_local_debug "Copy file (@map) $file => ${destdir}/$todir"
      			dirname=`dirname $file`
      			create_dir ${destdir}$todir
      			copy_file $file ${destdir}$todir
    		fi
  			# only copy file
  		else
    		echo_local_debug "Copy file (std) $file => $destdir/$dirname"
    		dirname=`dirname $file`
    		create_dir ${destdir}$dirname
    		copy_file $file ${destdir}$dirname
  		fi
  		i=$(( $i+1 ))
	done
}
#************ copy_filelist

#****f* std-lib.sh/is_mounted
#  NAME
#    is_mounted
#  SYNOPSIS
#    function is_mounted( path) {
#  DESCRIPTION
#    return 0 if path is mounted (means is a mountpoint) 1 otherwise
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function is_mounted {
    local dev=
    local path=
    local rest=

	[ -z "$MOUNTS" ] && MOUNTS=$(cat /proc/mounts)
	
    echo "$MOUNTS" | while read dev path rest; do
	   if [ "$path" = "$1" ]; then
          return 1
	   fi
    done || return 0 
    return 1
}
#*********** is_mounted

#****f* std-lib.sh/get_dep_filesystems
#  NAME
#    get_dep_filesystems
#  SYNOPSIS
#    function get_dep_filesystems( path, [excludelist]) {
#  DESCRIPTION
#    returns a list of paths dependently mounted on the given path. 
#    If excludelist is given all paths from this list are excluded.
#    The returnlist is returned in the order that always the longest path is first.
#    If the given path is not mounted 1 is returned to indicate the error.
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function get_dep_filesystems {
	local basepath=$1
	shift
	local excludepaths=$*
	local excludepath
	local dev=
	local path=
	local fs=
	local rest=
	local exclude=
	local returnpaths=
	local cleanmount=
	local rc=
	
	[ -z "$MOUNTS" ] && cleanmount=1
	[ -z "$MOUNTS" ] && MOUNTS=$(cat /proc/mounts)
	
	is_mounted $basepath || return 1
	
	echo "$MOUNTS" | while read dev path fs rest; do
		exclude=0
		if [ -n "$excludepaths" ]; then
		  for excludepath in $excludepaths; do
		  	if [ "${path:0:${#excludepath}}" = "$excludepath" ]; then
		  		exclude=1
		  	fi
		  done
		fi
		if [ $exclude -eq 0 ] && [ ${#path} -gt ${#basepath} ] && [ "${path:0:${#basepath}}" = "$basepath" ]; then
			echo $path
		fi
    done | sort -u -r
    rc=$?
    [ -n "$cleanmount" ] && unset MOUNTS
}
#************** get_dep_filesystems
######################
# $Log: stdfs-lib.sh,v $
# Revision 1.6  2009-10-08 08:00:05  marc
# better clean up in get_dep_filesystems
#
# Revision 1.5  2009/09/28 13:06:16  marc
# - implemented get_dep_filesystems
# - defined is_mounted vars as local
#
# Revision 1.4  2008/11/18 08:48:28  marc
# - implemented RFE-BUG 289
#   - possiblilty to execute initrd from shell or insite initrd to analyse behaviour
#