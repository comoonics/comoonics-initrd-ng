#!/bin/bash
#****h* comoonics-bootimage/create-gfs-initrd-generic.sh
#  NAME
#    create-gfs-initrd-generic.sh
#    $id$
#  DESCRIPTION
#*******
#
# $Id: create-gfs-initrd-generic.sh,v 1.34 2011/02/11 11:30:25 marc Exp $
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

exec 3>/dev/null
exec 4>/dev/null 5>/dev/null

predir=$(dirname $0)/boot-scripts

NOKMSG=1

source $predir/etc/std-lib.sh
sourceLibs $predir
sourceRootfsLibs $predir
source $(dirname $0)/create-gfs-initrd-lib.sh

lockfile=/var/lock/mkinitrd

cfg_file=/etc/comoonics/comoonics-bootimage.cfg

pwd=$(pwd)
force=0
TMPDIR=/tmp
mountpoint=$(mktemp -d ${TMPDIR}/initrd.mnt.XXXXXX)
#size=32768
size=120000

del_kernels=""
update=
index_list=".index.lst"
modules=""
pre_do=1
post_do=1

initEnv

PATH=${PATH}:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

#****f* create-gfs-initrd-generic.sh/usage
#  NAME
#    usage
#  SYNOPSIS
#    function usage() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function usage() {
  cat <<USAGE_EOF
$0 [-d dep_filename] [-s initrdsize] [-m mountpoint] [-r rpm-list-file] [-b build-date-file] 
[-V] [-F] [-R] [-o] [-l] [-L] [-M module]* 
[-U] [-A kernelversion]* [-D kernelversion]* 
initrdname kernel-version [kernel-version]*

This is the initrd ng tool. You should be able to build more complex and feature rich initrds. 
Up to now it is mainly used for building sharedroot clusters but can be also used to build initrd
for localfilesystems.

-d dep_filename: use another depfile listing the files to be included
-r rpm-list-file: use another depfile listing the rpms to be included
-s initrdsize: specify another initrdsize. This option is only valid if initrd is build as memory filesystem.
-m mountpoint: use a given "mountpoint" to build the initrd to
-b build-date-file: overwrite the default setting for the builddate file
-V: be more verbose
-F: ignore lockfiles
-R: don't remove the files added to the initrd afterwards
-o: use old initrd format (ramfilesystem)

-l: use lite initrd (only include necessary modules in initrd)
-L: include all actually loaded modules into this initrd
-M module : specify a module to be included in this initrd (can be specified multiple times)

-U: switch to update modes
-A kernelversion: add this kernelversion to this initrd (can be specified multiple times)
-D kernelversion: remove this kernelversion from this initrd  (can be specified multiple times)
-p: toggle pre  initrd generated skripts found in $pre_mkinitrd_path (default: $predo)
-P: toggle post initrd generated skripts found in $post_mkinitrd_path (default: $postdo)

initrdname: which file should be the initrd
kernel-version: which kernel version should be included in this initrd (=-A) (can be specified multiple times) 
USAGE_EOF
}

#************ usage
#****f* create-gfs-initrd-generic.sh/getoptions
#  NAME
#    getoptions
#  SYNOPSIS
#    function getoptions() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getoptions() {
    local i=0
    while getopts LUoRFVvhlpPm:fd:s:r:b:A:D:M: option ; do
	case "$option" in
	    v) # version
		echo "$0 Version "'$Revision: 1.34 $'
		exit 0
		;;
	    h) # help
		usage
		exit 0
		;;
	    m) # tempmount
		mountpoint="$OPTARG"
		;;
	    f) # force
		force=1
		;;
	    d) # depfile
		dep_filename="$OPTARG"
		;;
	    s) # size
		size="$OPTARG"
		;;
	    r ) # rpm-list
		rpm_list="$OPTARG"
		;;
	    b) # release file
		build_file="$OPTARG"
		;;
        V) # verbose mode
        verbose=1
        ;;
        F) # ignore locks
        Force=1
        ;;
        o) # use old initrd method
        initramfs=0
        ;;
        R) # don't remove temp dirs
        no_remove_tmp=1
	    ;;
        U) # only update
	    update=1
        ;;
	    l) # "light" initrd - only take used drivers
		light=1
		;;
        A) # add kernel to initrd (only in update mode)
        kernel[$i]=$OPTARG
        i=$(( $i + 1 ))
        ;;
        D) # del kernel from initrd (only in update mode)
        del_kernels="$del_kernels $OPTARG"
        ;;
        L) # include all loaded modules
        modules="$modules "$(awk '{ print $1; }' /proc/modules)
        ;;
        M) # add a specific module
        modules="$modules $OPTARG"
        ;;
        p) # toggle premkinitrd skripts execute
        pre_do=$((! $pre_do))
        ;;
        P) # toggle postmkinitrd skripts execute
        post_do=$((! $post_do))
        ;;
	    *)
		echo "Error wrong option."
		exit 1
		;;
	esac
    done
    shift $(($OPTIND - 1))
    initrdname=$1
    shift
    while [ -n "$1" ]; do
      kernel[$i]=$1
      shift
      i=$(( $i + 1 ))
    done
#    [ -z "${kernel[$i]}" ] && kernel[$i]="$(uname -r)"
}
#************ getoptions

#************ main
#****f* create-gfs-initrd-generic.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
initramfs=1

if [ -z "$1" ]; then
  usage
  exit
fi

if [ ${1:0:1} = "--" ]; then
    echo "detected request for old version of mkinitrd."
    echo "Params: $*"
    /sbin/mkinitrd $*
    exit $?
fi

source ${cfg_file}
getoptions $*

if [ -z "$update" ] && [ -z "$kernel" ]; then
  kernel[0]=$(uname -r)
fi

prgdir=${predir}

if [ -e $lockfile ] && [ -z "$Force" ]; then
  echo "Lockfile "$lockfile" exists. "
  echo "Another $(basename $0) is running. Please check if another process is running or remove the lockfile.."
  echo "..or start with force mode."
  exit 1
fi
touch $lockfile

kernelmajor=`echo ${kernel[0]} | cut -d . -f 1,2`

if [ "$kernelmajor" == "2.4" ] || [ "$initramfs" -eq 0 ]; then
    if [ -n "$verbose" ]; then echo "Creating old-style initrd"; fi
    USE_UDEV=
    RCFILE=$MNTIMAGE/linuxrc
else
    if [ -n "$verbose" ]; then echo "Creating initramfs"; fi
    modulefile=/etc/modprobe.conf
    initramfs=1
    RCFILE=$MNTIMAGE/init
fi

#if [ -e $netenv_file ]; then . $netenv_file; fi

if [ -z "$dep_filename" ] || [ ! -e "$dep_filename" ]; then
  echo "No depfile given. A dep_file is required." >&2
  echo "Hint: Is the package comoonics-bootimage-listfiles-<distro> installed ?" >&2
  usage
  rm $lockfile
  exit 1
fi

#if [ -z "$update" ] && ( [ -n "$kernel" ] || [ -n "$del_kernels" ] ); then
#	echo "Add or delete kernels given but not update mode selected." >&2
#	echo "Hint: You propably want to select update mode [-U]." >&2
#	usage 
#	rm $lockfile
#	exit 2
#fi

if [ "${initrdname:0:1}" != "/" ]; then
	initrdname="${pwd}/$initrdname"
fi 

if [ -z "$initramfs" ] || [ $initramfs -eq 0 ] && [ -n "$update" ]; then
	echo "You selected updatemode with old initrd method <ramfs>." >&2
	echo "This is not supported." >&2
    rm $lockfile
	exit 3
fi

if [ ! -e "$(dirname $initrdname)" ]; then
	echo "Path for initrd \"$initrdname\" does not exist. Please create path or validate the initrdname." >&2
    rm $lockfile
	exit 4
fi

if [ ! -e "$initrdname" ] && [ -n "$update" ]; then
	echo "You selected update but initrd \"$initrdname\" does not exist. Please fix." >&2
    rm $lockfile
	exit 5
fi

echo_local -n -N "Validating cluster configuration."
exec_local cc_validate
return_code
if [ $? -ne 0 ]; then
   errormsg err_cc_validate
   rm $lockfile
   exit 10
fi

if [ -z "$initramfs" ] || [ $initramfs -eq 0 ]; then
  echo_local -N -n "Makeing initrd ..."
  make_initrd $initrdname $size || (failure && rm $lockfile && exit $?)
  success

  echo_local -N -n "Mounting initrd ..."
  mount_initrd $initrdname $mountpoint || (failure && rm $lockfile && exit $?)
  success
fi

map_paths=$(get_mappaths_from_depfiles $dep_filename)

pushd $mountpoint >/dev/null 2>&1  	

if [ -d "$pre_mkinitrd_path" ] && [ -n "$pre_do" ] && [ $pre_do -eq 1 ]; then
  echo_local -N "Executing files before mkinitrd."
  exec_ordered_skripts_in $pre_mkinitrd_path $mountpoint
  if [ $? -ne 0 ]; then
  	rm $lockfile
  	exit $return_C
  fi
fi

if [ -z "$update" ]; then
  # extracting rpms
  if [ -n "$rpm_filename" ] && [ -e "$rpm_filename" ]; then
    echo_local -N -n "Extracting rpms..."
    #extract_all_rpms $rpm_filename $mountpoint $rpm_dir $verbose || echo "(WARNING)"
    rpmfilelist=$(get_filelist_from_rpms $rpm_filename $filters_filename $verbose)
    success
  fi

  echo_local -N -n "Retrieving dependent files..."
  # compiling marked perlfiles in this function
  #dep_files=$(get_all_depfiles $dep_filename $verbose)
  filelist=$(get_all_files_dependent $dep_filename $verbose)
  files=( $( ( echo $rpmfilelist; echo $filelist ) | tr ' ' '\n'| sort -u | grep -v "^.$" | grep -v "^..$" | tr '&' '\n') ) 
  echo ${files[@]} | tr ' ' '\n' > ${mountpoint}/file-list.txt
#  create_filelist $mountpoint > ${mountpoint}/$index_list
  echo_local -N -n "found "${#files[@]}" files" && success
else
  echo_local -N -n "Unpacking initrd ${initrdname} => ${mountpoint}.."
  unzip_and_uncpio_initrd $mountpoint $initrdname $force
  if [ ! -e "${mountpoint}/$index_list" ]; then
  	echo_local -N "Could not find valid index file."
  	echo_local -N -n "Autocreating index file .."
    create_filelist $mountpoint > ${mountpoint}/$index_list || (failure; echo "Could not create index file. Breaking." >&2; exit 5)
    success
  fi
  files=( $(PYTHONPATH=${predir}/etc python -c '
import stdlib
stdlib.get_files_newer(open("'$index_list'"), 
          { '$(create_python_dict_from_mappaths $(get_mappaths_from_depfiles $dep_filename))'
          	 "/":"/"} )') )
  if [ $? -ne 0 ]; then
    rm -rf ${mountpoint}/*
    rm $lockfile
    exit 11
  fi
  echo_local -N "Files to update "${#files[@]}
  if [ -n "$verbose" ]; then
    echo_local -N ${files[@]} | tr ' ' '\n'
  fi
fi

echo_local -N -n "Copying files..."
i=0
while [ $i -lt ${#files[@]} ]; do
  file=${files[$i]}
  if [ -d $file ] && [ ! -L $file ]; then
#    echo "Directory $file => ${mountpoint}/$file"
    create_dir ${mountpoint}/$file
    #copy_file $file ${mountpoint}/$(dirname $file)
  elif [ ! -e "$file" ] && [ "$file" = '@map' ]; then
    i=$(( $i+1 ))
    file=${files[$i]}
    i=$(( $i+1 ))
    todir=${files[$i]}
    if [ -d $file ]; then
      [ -n "$verbose" ] && echo "Directory mapping $file => ${mountpoint}/$todir"
      create_dir ${mountpoint}/$todir
      for file2 in $(ls -1 $file/*); do
         copy_file $file/\* ${mountpoint}/$todir/
      done
    else
      dirname=`dirname $file`
      create_dir ${mountpoint}$todir
      copy_file $file ${mountpoint}$todir
    fi
  elif [ ! -e "$file" ] && [ "$file" = '@mapfile' ]; then
    i=$(( $i+1 ))
    file=${files[$i]}
    i=$(( $i+1 ))
    fromdir=${files[$i]}
    i=$(( $i+1 ))
    todir=${files[$i]}
    subpath=$(dirname ${file#${fromdir}})
    [ -n "$verbose" ] && echo "File mapping ${file}#${fromdir} => ${mountpoint}/$todir/$subpath" >&2
    create_dir ${mountpoint}/$todir/$subpath
    copy_file $file ${mountpoint}/$todir/$subpath
  elif [ -e "$file" ]; then 
    dirname=`dirname $file`
    create_dir ${mountpoint}$dirname
    copy_file $file ${mountpoint}$dirname
  elif [ -n "$verbose" ]; then
    echo "File $file could not be found. Skipping." >&2
  fi
  i=$(( $i+1 ))
done
success

if [ -z "$update" ] || [ -n "$kernel" ]; then
  # first remove any kernel already specified
  if [ -n "$del_kernels" ]; then
  	for del_kernel in $del_kernels; do
  	  echo_local -N -n "Removing kernel $del_kernel"
  	  if [ -d ${mountpoint}/lib/modules/$del_kernel ]; then
  	    rm -rf ${mountpoint}/lib/modules/$del_kernel
  	  fi
  	  success
  	done
  fi
  # copying kernel modules
  for _kernel in ${kernel[@]}; do
    echo_local -N -n "Copying kernelmodules ($_kernel)..."

    if [ ! -d ${mountpoint}/lib/modules/$_kernel ]; then
      mkdir -p ${mountpoint}/lib/modules
    fi

    if [ -n "$light" ] && [ $light -eq 1 ]; then
	  # Only copy modules that are currently used or are specified in /etc/modprobe.conf
	  modules="true"
	  for module in $(get_min_modules $default_modules $modules | sort -u); do
	     modules="-name ${module}.ko -or $modules"
	  done
      findcmd="find /lib/modules/$_kernel $modules"
    else
      args=$(get_global_filters $filters_filename | awk '{printf(" -regex %s -or", $0);} END { print " -false"; }')
	  # no globbing
      findcmd="find /lib/modules/$_kernel \( -type f -or -type l \) -and -not \( $args \)"
    fi
    cpioopts="--pass-through --make-directories"
    if [ -n "$verbose" ]; then
      echo_local -N "Calling find with $findcmd"
      cpioopts="$cpioopts --verbose"
    fi
    set -f
    eval $findcmd | cpio $cpioopts $mountpoint
    set +f
    if [ $? -eq 0 ]; then
      success
    else
      failure && rm $lockfile && exit $?
    fi
  done
fi

#for module in $FC_MODULE $FC_MODULES $GFS_MODULES; do
#  dirname=`dirname ${MODULES_DIR}/${module}`
#  create_dir ${mountpoint}$dirname
#  copy_file ${MODULES_DIR}/${module} ${mountpoint}$dirname
#done

#echo "The following files reside on the image:"
#find .
if [ -z "$update" ]; then
  echo_local -N -n "Post settings .."
  chown -R root:root $mountpoint
  if [ -z "$initramfs" ] || [ $initramfs -eq 0 ]; then
    if [ ! -e ${mountpoint}/linuxrc ] && [ -e ${mountpoint}/init ]; then
      cd $mountpoint && ln -s init linuxrc
      cd $pwd
    fi
  else
    if [ -e ${mountpoint}/linuxrc ] && [ ! -e ${mountpoint}/init ]; then
      cd $mountpoint && ln -s linuxrc init
      cd $pwd
    fi
  fi
  success
fi

if [ -d "$post_mkinitrd_path" ] && [ -n "$post_do" ] && [ $post_do -eq 1 ]; then
  echo_local -N "Executing files after mkinitrd."
  exec_ordered_skripts_in $post_mkinitrd_path $mountpoint
  if [ $? -ne 0 ]; then
  	rm $lockfile
  	exit $return_c
  fi
fi

create_builddate_file $build_file # && success || failure

echo_local -N -n "Creating index file .."
create_filelist $mountpoint > ${mountpoint}/$index_list || (failure; echo "Could not create index file. Breaking." >&2; exit 5)
success

if [ -z "$initramfs" ] || [ $initramfs -eq 0 ]; then
  cd $pwd
  echo_local -N -n "Unmounting and compressing.."
  (umount_and_zip_initrd $mountpoint $initrdname $force && \
   rm $lockfile) || (failure && rm $lockfile && exit $?)
else
  echo_local -N -n "Cpio and compress.."
  (cpio_and_zip_initrd $mountpoint $initrdname "$force" "$TMPDIR" && \
   rm $lockfile) || (failure && rm $lockfile && exit $?)
fi
success

cd $pwd
if [ -z "$no_remove_tmp" ]; then
  echo_local -N -n "Cleaning up ($mountpoint, $no_remove_tmp)..."
  rm -fr $mountpoint
  success
fi
ls -lk $initrdname
#************ main

##########################################
# $Log: create-gfs-initrd-generic.sh,v $
# Revision 1.34  2011/02/11 11:30:25  marc
# - fixed bug that with update mode relative files to initrd would not work.
#
# Revision 1.33  2010/12/07 13:30:28  marc
# moved a line
#
# Revision 1.32  2010/08/11 09:44:50  marc
# honor errors caused by exec_orderered_skripts in pre and post execution
#
# Revision 1.31  2010/07/08 08:39:24  marc
# speed up copy of kernel modules in one run using cpio --pass-through instead of tar and for clause
#
# Revision 1.30  2010/06/29 19:01:25  marc
# long options to tar
#
# Revision 1.29  2010/05/27 09:54:52  marc
# add TMPDIR as parameter to cpio_and_zip_initrd
#
# Revision 1.28  2010/02/21 12:09:32  marc
# fixed bug in copy of kernel modules were linked modules would not be copied.
#
# Revision 1.27  2010/02/05 12:52:52  marc
# - added pre and postdo functionality where skripts/programs might be executed before or after building initrd
# - -p/-P toggles if pre and postscripts should be executed or not.
# - added -N to echo_local, echo_local_debug where appropriate
# - filtering kernel modules if filters are specified
#
# Revision 1.26  2009/09/28 14:22:13  marc
# - added way to execute commands in $pre/post_mkinitrd_path
#
# Revision 1.25  2009/06/05 07:29:06  marc
# - fixed bug #347 where the -M option would not work
#
# Revision 1.24  2009/04/20 07:42:54  marc
# - fixed error detection
#
# Revision 1.23  2009/04/14 15:05:24  marc
# bugfix for Bug#343
#
# Revision 1.22  2009/04/03 17:30:43  marc
# - added usage
# - added update feature
#
# Revision 1.21  2009/03/25 13:55:20  marc
# - added global filters to filter files from initrd
#
# Revision 1.20  2009/02/24 12:10:44  marc
# moved default lockfile
# multiple kernel modules in initrd
#
# Revision 1.19  2009/02/17 20:05:44  marc
# small typo
#
# Revision 1.18  2009/02/08 14:22:22  marc
# added the diet patch from gordan
#
# Revision 1.17  2009/01/28 13:07:21  marc
# - use load std-lib.sh the helperfunctions sourceLibs sourceRootfsLibs to load libraries
#
# Revision 1.16  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.15  2007/09/13 08:36:08  mark
# added fancy error help message
#
# Revision 1.14  2007/09/07 07:57:06  mark
# removed bug, that liks to directories where not copied
#
# Revision 1.13  2007/08/06 16:02:17  mark
# reorganized files
# added rpm filter support
#
# Revision 1.12  2007/02/09 11:08:53  marc
# creating builddate_file with predefined function
#
# Revision 1.11  2006/08/28 16:01:45  marc
# support for rpm-lists and includes of new lists
#
# Revision 1.10  2006/07/13 11:35:36  marc
# new version changing file xtensions
#
# Revision 1.9  2006/06/19 15:55:28  marc
# rewriten and debuged parts of generating deps. Added @include tag for depfiles.
#
# Revision 1.8  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.7  2006/05/03 12:47:10  marc
# added documentation
#
# Revision 1.6  2006/02/03 12:39:27  marc
# preset includes.
# Changed bug for build initrd with loopfs
#
# Revision 1.5  2006/01/25 14:57:42  marc
# new build process bugfixes
#
