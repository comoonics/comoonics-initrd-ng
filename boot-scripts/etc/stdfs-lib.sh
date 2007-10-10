#
# $Id: stdfs-lib.sh,v 1.2 2007-10-10 12:19:41 mark Exp $
#
# @(#)$File$
#
# Copyright (c) 2007 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
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