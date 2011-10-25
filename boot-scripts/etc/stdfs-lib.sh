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
    elif [ ! -e "$file" ] && [ "${file:0:4}" = '@map' ]; then
      echo "${file}"
      todir=$(echo "${file}" | cut -f3 -d'&')
      file=$(echo "${file}" | cut -f2 -d'&')
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
      echo "${file}"
      todir=$(echo "${file}" | cut -f4 -d'&')
      fromdir=$(echo "${file}" | cut -f3 -d'&')
      file=$(echo "${file}" | cut -f2 -d'&')
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

#****f* std-lib.sh/get_filesystem
#  NAME
#    get_filesystem
#  SYNOPSIS
#    function get_filesystem( path, [excludelist]) {
#  DESCRIPTION
#    returns a list of values of the filesystem mounted on the path <path> (only the first one to be found).
#    This function returns "" and $?!=0 if no filesystem can be found under <path>.
#    Otherwise $?==0 will be set and it will output a list of values seperated by OFS which defaults to " ".
#    The values output are as follows:
#        device the path is mounted
#        path
#        filesystem type
#        mountoptions this filesystem is mounted with 
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function get_filesystem {
	# strip the path
	local path=$(echo "$1" | sed -e 's/\/\/\/*/\//g' | sed -e 's/^\(..*\)\/\/*$/\1/')
	shift
	local dev=
	local excludepaths=$*
	local excludepath
	local curpath=
	local fs=
	local rc=
	local mountopts=
	local found=1
	
	[ -z "$MOUNTSFILE" ] && local MOUNTSFILE="/proc/mounts"
	[ -z "$OFS" ] && local OFS=" "
	
	# This is a subshell.
	while read dev curpath fs mountopts rest; do
		exclude=0
		if [ -n "$excludepaths" ]; then
		  for excludepath in $excludepaths; do
		  	if [ "${path}" = "$excludepath" ] || [ "${dev}" = "$excludepath" ] ; then
		  		exclude=1
		  	fi
		  done
		fi
		if [ $exclude -eq 0 ] && [ ${#curpath} -eq ${#path} ] && [ "${curpath}" = "$path" ]; then
		  echo "${dev}${OFS}${curpath}${OFS}${fs}${OFS}${mountopts}"
		  found=0
		fi
    done < $MOUNTSFILE
    return $found
}
#************** get_dep_filesystems

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

#****f* std-lib.sh/parse_cdsltab
#  NAME
#    parse_cdsltab
#  SYNOPSIS
#    function parse_cdsltab(filterfunc="exclude_initrd_mountpoints") {
#  DESCRIPTION
#    Parses the cdsltab (from stdin) for mounting filesystems that cannot be represented by the /etc/fstab.
#    Those filesystems might be cdslmounts or special filesystems that somehow hostdependent parts.
#    With the __initrd mountoption this filesystem is mounted within the initrd and will be left out by default.
#    This filtering can be overruled by specifying another filter function. 
#    By default exclude_initrd_mountpoints will be used (see exclude_initrd_mountpoints, only_initrd_mountpoints).
#    The /etc/cdsltab format is as follows
#    cdsltab        ::= line+
#    line           ::= cdslmountline|mountline
#    cdslmountline  ::= cdslfsmountpoint [mountopts]
#    mountline      ::= fstype source dest mountopts mounttimes mountwait
#    mountopts      ::= [ allfsmountopts|"__initrd" ]*
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function parse_cdsltab {
    local filterfunc=${1:-exclude_initrd_mountpoints}
    local newroot=${2:-/}
    
    while read line; do
        if $filterfunc $line; then
            # remove the __initrd mountoption if available
            line=${line%,__initrd}
            line=${line%__initrd,}
            line=${line%__initrd}
            line=$(echo "$line" | replace_param_in nodeid $(repository_get_value nodeid 1))
            # if more then 2 arguments are read from line we suppose this is a filesystem to be mounted
            opts=( $line )
            if [ ${#opts[@]} -le 2 ]; then
                clusterfs_mount_cdsl ${opts[@]} 
            else
                clusterfs_mount ${opts[@]}
            fi
        fi
      done
}
#************ parse_cdsltab

#****f* std-lib.sh/exclude_initrd_mountpoints
#  NAME
#    exclude_initrd_mountpoints
#  SYNOPSIS
#    function exclude_initrd_mountpoints(cdsltabline) {
#  DESCRIPTION
#    runs the filter over the cdsltabline that will return 1 if mountopts include __initrd or not (return 0)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function exclude_initrd_mountpoints {
    local mountopts=${4:-${2}}
    
    [ -z "$mountopts" ] || echo $mountopts | grep -v "__initrd" > /dev/null
}
#************ exclude_initrd_mountpoints

#****f* std-lib.sh/only_initrd_mountpoints
#  NAME
#    only_initrd_mountpoints
#  SYNOPSIS
#    function only_initrd_mountpoints(cdsltabline) {
#  DESCRIPTION
#    runs the filter over the cdsltabline that will return 0 if mountopts include __initrd or not (return 1)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function only_initrd_mountpoints {
    local mountopts=${4:-${2}}
    
    [ -n "$mountopts" ] && echo $mountopts | grep "__initrd" > /dev/null
}
#************ only_initrd_mountpoints

#****f* std-lib.sh/replace_param_in
#  NAME
#    replace_param_in
#  SYNOPSIS
#    function replace_param_in(paramname, value, exp=%(paramname)s) {
#  DESCRIPTION
#    replaces all occurences of paramname in the format exp with string paramname replaced with 
#    the value of paramname and output it to stdout.
#    Read is from stdin.  
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function replace_param_in {
    local paramname=$1
    local value=$2
    local exp=${3:-%(paramname)s}
    
    if [ -z "$paramname" ] || [ -z "$exp" ]; then
        exp=""
    else
        exp=$(echo "$exp" | sed -e 's/paramname/'$paramname'/')
    fi
    while read line; do
        echo "$line" | sed -e 's/'$exp'/'$value'/g'
    done
}
#************ replace_param_in
