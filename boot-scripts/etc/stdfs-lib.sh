#
# $Id: stdfs-lib.sh,v 1.11 2010-07-08 08:12:37 marc Exp $
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
# Binaries
STAT="$(which stat)"
COPY="$(which cp)"
MOVE="$(which mv)"
MKDIR="$(which mkdir)"

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
  local dinode=$(/bin/ls $lsopt -i $dest 2>/dev/null | awk '{print $1}')
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
#  if is_modified $source $dest then
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
#    function copy_file( destdir)
#  DESCRIPTION
#    copy files got from stdin.
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function copy_filelist() {
  local destdir=$1
  local file2=
  local todir=

  shift
  if ! [ -d "$destdir" ]; then
    error_local -N "$destdir is not a directory"
    return 1
  fi	
  while read file; do
    # this is a directory and not a symbolic link
    if [ -d "$file" ] && [ ! -L "$file" ]; then
      echo "$file"
      create_dir ${destdir}/$file
    # if we are a mapping to another directory read more information
    elif [ ! -e "$file" ] && [ "$file" = '@map' ]; then
      read file
      read todir
      echo "@map $file $todir"
      if [ -d $file ]; then
        echo_local_debug -N "Directory mapping $file => ${destdir}/$todir" >&2
        create_dir ${destdir}/$todir
        for file2 in $(ls -1 $file/*); do
          copy_file $file/\* ${destdir}/$todir/
        done
      else
        dirname=`dirname $file`
        create_dir ${destdir}$todir
        copy_file $file ${destdir}$todir
      fi
    # we are a filemapping file
    elif [ ! -e "$file" ] && [ "$file" = '@mapfile' ]; then
      read file
      read fromdir
      read todir
      echo "@mapfile $file $fromdir $todir"
      subpath=$(dirname ${file#${fromdir}})
      echo_local_debug -N "File mapping ${file}#${fromdir} => ${destdir}/$todir/$subpath" >&2
      create_dir ${destdir}/$todir/$subpath
      copy_file $file ${destdir}/$todir/$subpath
    # else we are a normal existant file
    elif [ -e "$file" ]; then 
      echo "$file"
      dirname=`dirname $file`
      create_dir ${destdir}$dirname
      copy_file $file ${destdir}$dirname
	else
      echo_local_debug -N "File $file could not be found. Skipping." >&2
    fi
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
    local mountpoint=$(echo "$1" | sed -e 's/\/\/\/*/\//g' | sed -e 's/^\(..*\)\/\/*$/\1/')
    local mountset=

	if [ -z "$MOUNTS" ]; then 
	  MOUNTS=$(cat /proc/mounts)
      mountset=1
    fi	  
	[ -n "$MOUNTSFILE" ] && MOUNTS=$(cat $MOUNTSFILE)
	
    echo "$MOUNTS" | while read dev path rest; do
	   if [ "$path" = "$mountpoint" ]; then
	   	  [ "$mountset" = "1" ] && unset MOUNTS
          return 1
	   fi
    done
    if [ $? -ne 0 ]; then
        [ "$mountset" = "1" ] && unset MOUNTS
    	return 0
    else 
        [ "$mountset" = "1" ] && unset MOUNTS
        return 1
    fi
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
	local basepath=$(echo "$1" | sed -e 's/\/\/\/*/\//g' | sed -e 's/^\(..*\)\/\/*$/\1/')
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
	
	[ -z "$MOUNTSFILE" ] && local MOUNTSFILE="/proc/mounts"
	
	is_mounted $basepath || return 1
	
    local paths=
	while read dev path fs rest; do
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
    done < $MOUNTSFILE | sort -u -r
    rc=$?
}
#************** get_dep_filesystems

#****f* std-lib.sh/umount_filesystem
#  NAME
#    umount_filesystem
#  SYNOPSIS
#    function umount_filesystem( path, killdepservices) {
#  DESCRIPTION
#    Umounts the given filesystem and kills all dependent service if killdepservices is set.
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function umount_filesystem {
	local _filesystem=$1
	local killsvc=$2
	
	if [ -n "$killsvc" ]; then
	  fuser -m $_filesystem &> /dev/null &&
      fuser -km -15 $_filesystem &> /dev/null
      sleep 2
      fuser -m $_filesystem &> /dev/null &&
      fuser -km -9 $_filesystem &> /dev/null
	fi
    umount $_filesystem
}
#************ umount_filesystem
######################
# $Log: stdfs-lib.sh,v $
# Revision 1.11  2010-07-08 08:12:37  marc
# - is_same_inode: dropping error messages
#
# Revision 1.10  2010/06/08 13:45:15  marc
# - is_mounted: trimming of mountpoint given
#
# Revision 1.9  2010/03/29 18:36:28  marc
# - change copy_filelist to only copy if file is changed.
#
# Revision 1.8  2010/01/04 13:15:26  marc
# get_dep_mountpoints and is_mounted may not point to /proc/mounts
#
# Revision 1.7  2009/12/09 09:26:57  marc
# fixed bug in get_dep_filesystems
#
# Revision 1.6  2009/10/08 08:00:05  marc
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
