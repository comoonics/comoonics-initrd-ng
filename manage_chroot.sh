#!/bin/bash

#****h* comoonics-bootimage/update_chroot.sh
#  NAME
#    update_chroot.sh
#    
#  DESCRIPTION
#*******
#
# $Id: manage_chroot.sh,v 1.22 2011-01-28 13:02:21 marc Exp $
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

if [ -f /etc/sysconfig/comoonics-chroot ]; then
	source /etc/sysconfig/comoonics-chroot
fi

# include libraries

if ! [ -e $(dirname $0)/boot-scripts/etc/std-lib.sh ]; then
  echo "Cannot find $(dirname $0)/boot-scripts/etc/stdfs-lib.sh"
  exit 1
fi

source $(dirname $0)/boot-scripts/etc/std-lib.sh
source $(dirname $0)/boot-scripts/etc/repository-lib.sh
repository_clear
sourceLibs $(dirname $0)/boot-scripts
clutype=$(repository_get_value clutype)
rootfs=$(get_mounted_rootfs)
repository_store_value rootfs $rootfs
sourceRootfsLibs $(dirname $0)/boot-scripts
distribution=$(repository_get_value distribution)
[ -z $MKCDSLINFRASTRUCTURE ] && MKCDSLINFRASTRUCTURE=com-mkcdslinfrastructure

# overwrite with bootparameter if need be
chrootneeded=$(getParameter chrootneeded 2>/dev/null)
if [ "$(repository_get_value chrootneeded)" = "__set__" ]; then
	repository_store_value chrootneeded 0
	chrootneeded=0
fi 
if [ -z "$chrootneeded" ]; then
  clusterfs_chroot_needed init
  __default=$?
  chrootneeded=$(getParameter chroot $__default)
fi
initEnv

# dep_filename is the file where all dependent files are to be taken from
dep_filename_chroot=/etc/comoonics/bootimage-chroot/files.list
# rpm_filename is the file where all dependent files are to be taken from
rpm_filename_chroot=/etc/comoonics/bootimage-chroot/rpms.list
# filter_filename is the file where all dependent files are to be taken from
filters_filename_chroot=/etc/comoonics/bootimage-chroot/filter.list
#
# path to scripts to be executed before collecting files
pre_updatechroot_path=/etc/comoonics/bootimage-chroot/pre.updatechroot.d
#
# path to scripts to be executed after update chroot has been finished
post_updatechroot_path=/etc/comoonics/bootimage-chroot/post.updatechroot.d
# where save the cachefiles
cachedir=/var/cache/comoonics-bootimage
# filesystems
UMOUNTFS="/dev/pts /dev /proc /sys"

cfg_file=/etc/comoonics/comoonics-bootimage.cfg
source ${cfg_file}

repository_store_value hardwareids "$(hardware_ids)"

function usage() {
	cat<<EOF
`basename $0` [ [-h] | [-v] ] -a action
  -h help 
  -v be chatty
  -d debug (even more chatty)
  -V show version
  -p print chroot path
  -a action - action to perform
     update - updates the chroot environment with files defined in 
              /etc/comoonics/bootimage-chroot/files.list
              /etc/comoonics/bootimage-chroot/rpms.list
     umount - umounts pts (needed for reboot
     start_service <commannd>    - starts a service in chroot
     stop_service_pid <pidfile>  - kills a service with pidfile in chroot
     stop_service_cmd <command>  - kills all services with name <command> TODO: in chroot
     status_service_pid <pidfile>  - returns status of service with pidfile in chroot
     status_service_cmd <command>  - returns status of service with name <command> TODO: in chroot
     mount_cdsl mountpoint [root] [<cdslpath>] [<cdsllocal>] - mounts the cdsl environment [again]
     umount_cdsl mountpoint [root] - umounts the cdsl environment for the given mountpoint
     status_cdsl mountpoint [root] [<cdslpath>] [<cdsllocal>] - checks for status of cdsl environment of this mountpoint
     clean - clean all cached items
     
EOF
}


# TO DO move functions to boot-lib.sh
function log() {
	if [ "$verbose" ]; then
		echo_local $@
	else 
		echo_out $@
	fi 
}

function close_fds() {
	exec 3>&-
	exec 4>&-
	exec 5>&-
	exec 6>&-
	exec 7>&-	
}

function umount_chroot() {
	for dir in $UMOUNTFS; do 
	   echo_local -n -N "..$dir.."
	   umount_filesystem $chrootdir/$dir & >/dev/null
	done
}

function mount_chroot() {
	local retc=0
	local subdir fstype device
	local i=
	mounts=( "/dev/pts" "devpts" "none"  "/proc" "proc" "proc" "/sys" "sysfs" "sysfs" )
	for file in /dev/.initramfs/comoonics.*; do
		cp $file $REPOSITORY_PATH
	done
	chrootdir=${chrootdir:-$(repository_get_value chroot_path)}
	if [ -z "$chrootdir" ]; then
		return 1
	fi
	# We end up in this clause only if we need a chroot but there is none yet.
	if [ -z "$chrootdir" ]; then
  		echo_local -n "Building comoonics chroot environment \"$chrootdir\" "
  		res=( $(build_chroot $(repository_get_value nodeid)) )
  		retc=$?
  		repository_store_value chroot_mount ${res[0]}
  		#FIXME: chroot_path should be the same as chrootdir but what to do here? How to decide?
  		repository_store_value chroot_path ${res[1]}
		echo_local -n -N "res: $res -> chroot_mount="$(repository_get_value chroot_mount)", chroot_path="$(repository_get_value chroot_path)
		return_code $retc 
	fi
	# chrootdir is mounted but not written to /etc/mtab
	if [ ! -L /etc/mtab ] && ! MOUNTS=$(cat /etc/mtab) is_mounted $chrootdir && is_mounted $chrootdir && repository_has_key nodename; then
		echo_local -N -n "persist "
		res=( $(build_chroot_fake $(repository_get_value nodeid)) )
  		retc=$?
  		repository_store_value chroot_mount ${res[0]}
  		#FIXME: chroot_path should be the same as chrootdir but what to do here? How to decide?
  		repository_store_value chroot_path ${res[1]}
  		echo_local_debug -N -n "chroot_mount: ${res[0]}, chroot_path: ${res[1]} res: ${res[@]} "
	fi 
	echo_local -N -n "subdirs "
	while [ ${#mounts} -gt 0 ]; do
		local subdir=${mounts[0]}
		local fstype=${mounts[1]}
		local device=${mounts[2]}
		mounts=( ${mounts[@]:3} )
		if ! is_mounted "${chrootdir}${subdir}" && ! is_mounted $(repository_get_value cdsl_local_dir)${chrootdir}${subdir}; then
			echo_local -N -n "..$chrootdir${subdir}.."
			#echo_local_debug -N -n ".. mount -t $fstype $device $chrootdir${subdir}.."
			mkdir -p $chrootdir${subdir} >/dev/null 2>&1
			mount -t $fstype $device $chrootdir${subdir}
        elif ! MOUNTS=$(cat /etc/mtab) is_mounted "${chrootdir}${subdir}" && is_mounted "${chrootdir}${subdir}"; then
            echo_local -N -n "..$chrootdir${subdir}.."
            mkdir -p $chrootdir${subdir} >/dev/null 2>&1
            mount -f -t $fstype $device $chrootdir${subdir}
		fi
	done
	unset mounts
	true
}

function stop_service_pid() {
	local pfile=$1
	if [ -e $chrootdir/$pfile ]; then
		kill $(cat $chrootdir/$pfile)
	fi
}

function stop_service_cmd() {
	local cmd=$1
	chroot $chrootdir killall $cmd	
}

function status_service_pid() {
	local pfile=$1
	[ -e $chrootdir/$pfile ] || exit 1
	kill -0 $(cat $chrootdir/$pfile) &> /dev/null
}

function status_service_cmd() {
	local cmd=$1
	killall -0 $cmd	
}

function update_chroot() {
	#log -n "starting update_chroot "
	local rc=0
	local rpmfilelist=
	local filelist=
	local files=
	local dep_filename=$1
	local rpm_filename=$2
	local filters_filename=$3
	local pre_mkinitrd_path=$4
	local post_mkinitrd_path=$5
	local chrootdir=$6
	local cachedir=$7
	local indexfile=${8:-"file-list-chroot.txt"}

	if [ ! -e $dep_filename ]; then
		echo_local "dependency file $dep_filename does not exist"
		exit 1
	fi

	if [ ! -e $rpm_filename ]; then
		echo_local "rpm_filename $rpm_filename does not exist!"
		exit 1
	fi

	if [ ! -e "$cachedir" ]; then
		echo_local -n -N "Cachedir $cachedir does not exist creating.."
		mkdir -p $cachedir
	fi

	if [ -d "$pre_mkinitrd_path" ]; then
      echo_local -N "Executing files before update chroot."
      exec_ordered_scripts_in $pre_mkinitrd_path $chrootdir
      [ $rc -eq 0 ] && rc=$?
    fi
    if [ -z "$cachedir" ] || [ ! -e "${cachedir}/$indexfile" ] ; then
	  # extracting rpms
	  if [ -n "$rpm_filename" ] && [ -e "$rpm_filename" ]; then
		echo_local -N -n "rpmfiles.."
	    rpmfilelist=$(get_filelist_from_rpms $rpm_filename $filters_filename $verbose)
		[ $rc -eq 0 ] && rc=$?
	  fi

	  echo_local -N -n "dependent files "

      filelist=$(get_all_files_dependent $dep_filename $verbose)
	  [ $rc -eq 0 ] && rc=$?
      echo_local -N -n "copying ($chrootdir ${cachedir}/$indexfile)... "
      ( echo $rpmfilelist; echo $filelist ) | tr ' ' '\n'| sort -u | grep -v "^.$" | grep -v "^..$" | tr '&' '\n' | copy_filelist $chrootdir > ${cachedir}/$indexfile
      [ $rc -eq 0 ] && rc=$?
	else
	  cat ${cachedir}/$indexfile | copy_filelist $chrootdir > ${cachedir}/$indexfile
      [ $rc -eq 0 ] && rc=$?
    fi
	
	if [ -d "$post_mkinitrd_path" ]; then
      echo_local -N "Executing files after update chroot."
      exec_ordered_scripts_in $post_mkinitrd_path $chrootdir
      [ $rc -eq 0 ] && rc=$?
    fi
	
	return $rc
}

function mount_cdsl {
    local mountpoint=$1
    local root=$2
	local cdsl_path=$3
	local cdsl_local=$4
	local filesystem=$5

	local nodeid=$(getParameter nodeid $(cc_getdefaults nodeid))
	
    [ -z "$mountpoint" ] && mountpoint="/"
    [ -z "$root" ] && root="/"
	[ -z "$filesystem" ] && filesystem=$rootfs
	
    $MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --list &>/dev/null
    if [ $? -ne 0 ]; then
       error_local -n "Could not find cdsl on mountpoint $mountpoint."
       failure
       return 1
    fi
	[ -z "$cdsl_path" ] && cdsl_path=$($MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --get=tree)
	[ -z "$cdsl_local" ] && cdsl_local=$($MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --get=link)
	
	if [ -z "$nodeid" ]; then
		echo_local "Could not detect nodeid. Therefore I couldn't mount $cdsl_path" >&2
		exit 1
	fi
    
    # cdsl environment is mounted but not in mtab then remount
    if check_mtab "$filesystem" $mountpoint $cdsl_path $cdsl_local; then
       clusterfs_mount_cdsl $mountpoint $cdsl_local $nodeid $cdsl_path
    fi
    if ! is_mounted $mountpoint/$cdsl_local; then
       clusterfs_mount_cdsl $mountpoint $cdsl_local $nodeid $cdsl_path
    else
       echo_local -n "cdsl filesystem $mountpoint is already setup. skipping."
       passed 
    fi	
}

function status_cdsl() {
    local mountpoint=$1
    local root=$2
	local cdsl_path=$3
	local cdsl_local=$4
	local filesystem=$5

	local nodeid=$(getParameter nodeid $(cc_getdefaults nodeid))
	
    [ -z "$mountpoint" ] && mountpoint="/"
    [ -z "$root" ] && root="/"
	[ -z "$filesystem" ] && filesystem=$rootfs
	
    $MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --list &>/dev/null
    if [ $? -ne 0 ]; then
       error_local -n "Could not find cdsl on mountpoint $mountpoint."
       failure
       return 1
    fi
	[ -z "$cdsl_path" ] && cdsl_path=$($MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --get=tree)
	[ -z "$cdsl_local" ] && cdsl_local=$($MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --get=link)
	
	if [ -z "$nodeid" ]; then
		echo_local "Could not detect nodeid. Therefore I couldn't mount $cdsl_path" >&2
		exit 1
	fi
	
	if is_mounted $mountpoint/$cdsl_local; then
	   $MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --list
	   return 0
	else
	   error_local -n "Cdsl infrastructure not available or not mounted at $mountpoint."
	   failure
	   return 1
	fi
}


function umount_cdsl() {
    local mountpoint=$1
    local root=$2
	local cdsl_path=$3
	local cdsl_local=$4
	local filesystem=$5

	local nodeid=$(getParameter nodeid $(cc_getdefaults nodeid))
	
    [ -z "$mountpoint" ] && mountpoint="/"
    [ -z "$root" ] && root="/"
	[ -z "$filesystem" ] && filesystem=$rootfs
	
    $MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --list &>/dev/null
    if [ $? -ne 0 ]; then
       error_local -n "Could not find cdsl on mountpoint $mountpoint."
       failure
       return 1
    fi
	[ -z "$cdsl_path" ] && cdsl_path=$($MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --get=tree)
	[ -z "$cdsl_local" ] && cdsl_local=$($MKCDSLINFRASTRUCTURE --mountpoint=$mountpoint --root=$root --get=link)
	
	if [ -z "$nodeid" ]; then
		echo_local "Could not detect nodeid. Therefore I couldn't mount $cdsl_path" >&2
		exit 1
	fi
	
	if is_mounted $mountpoint/$cdsl_local; then
	   echo_local -n "Umounting cdsl infrastructure on $mountpoint."
	   for filesystem in $(get_dep_filesystems $mountpoint/$cdsl_local); do
	      umount_filesystem $filesystem "killsvc"
	   done
	   exec_local umount_filesystem $mountpoint/$cdsl_local
	   return_code $?
	   return 0
	else
	   error_local -n "Cdsl infrastructure not mounted under $mountpoint."
	   failure 
	   return 1
	fi
}
function createxfiles {
	repository_store_value xtabfile /etc/xtab
	repository_store_value xrootfsfile /etc/xrootfs
	repository_store_value xkillallprocsfile /etc/xkillall_procs
	clusterfs_chroot_needed initrd
	__default=$?
	getParameter chrootneeded $__default &>/dev/null
	if  [ ! -e $(repository_get_value xtabfile) ]; then
	  echo_local -n "Writing xtab.. "
	  if [ $(repository_get_value chrootneeded) -eq 0 ]; then
  		create_xtab "$(repository_get_value xtabfile)" "$(repository_get_value cdsl_local_dir)" "$(repository_get_value chroot_mount)" 
	  else  
  		create_xtab "$(repository_get_value xtabfile)" "$(repository_get_value cdsl_local_dir)"
	  fi
	  success
    fi

	if [ ! -e $(repository_get_value xrootfsfile) ]; then
	  echo_local -n "Writing xrootfs.. "
	  create_xrootfs $(repository_get_value xrootfsfile) $(repository_get_value rootfs)
	  success
	fi

    if [ ! -e $(repository_get_value xkillallprocsfile) ]; then
	  echo_local -n "Writing xkillall_procs.. "
	  create_xkillall_procs $(repository_get_value xkillallprocsfile) "$(repository_get_value clutype)" "$(repository_get_value rootfs)"
	  success
    fi
}	

#****f* bootsr/patch_files
#  NAME
#    patch_files
#  SYNOPSIS
#    function patch_files
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function patch_files {
  local files="halt network netfs"
  local patchfiles=
  local initdpath="/etc/rc.d/init.d"
  local bootimagepath="/opt/atix/comoonics-bootimage/patches/"
  local bakext="com_bak"
  if [ -n "$1" ]; then
    files=$*
  fi
  # we patch all versions here
  for initscript in $files; do
	if [ -f "${initdpath}/$initscript" ] && [ -f ${bootimagepath}/$initscript ] && ! diff ${initdpath}/$initscript ${bootimagepath}/$initscript >/dev/null; then
		echo -n "Updateing $initscript ("
		cp -f ${initdpath}/$initscript ${initdpath}/${initscript}.${bakext}
		cp -f /opt/atix/comoonics-bootimage/patches/$initscript $initdpath 
	    echo ")"
	fi
  done
}
#************ patch_files

#****f* bootsr/unpatch_files
#  NAME
#    unpatch_files
#  SYNOPSIS
#    function unpatch_files
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function unpatch_files {
  local files="halt network netfs"
  local patchfiles=
  local initdpath="/etc/rc.d/init.d"
  local bootimagepath="/opt/atix/comoonics-bootimage/patches/"
  local bakext="com_bak"
  if [ -n "$1" ]; then
    files=$*
  fi
  # we patch all versions here
  for initscript in $files; do
	if [ -f "${initdpath}/$initscript" ] && [ -f ${initdpath}/${initscript}.${bakext} ] && ! diff ${initdpath}/$initscript ${initdpath}/${initscript}.${bakext} >/dev/null; then
		echo -n "Restoring $initscript ("
		cp -f ${initdpath}/${initscript}.${bakext} ${initdpath}/${initscript}
		rm -f ${initdpath}/${initscript}.${bakext}
	    echo ")"
	fi
  done
}
#************ unpatch_files

#****f* bootsr/check_sharedroot
#  NAME
#    check_sharedroot
#  SYNOPSIS
#    function check_sharedroot
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function check_sharedroot {
  local root_fstype=$1
  if [ "$root_fstype" = "gfs" ] || [ "$root_fstype" = "ocfs2" ] || [ "$root_fstype" = "nfs" ] || [ "$root_fstype" = "glusterfs" ]; then
    return 1
  else
    return 0
  fi
}
#************ check_sharedroot

#include /etc/sysconfig/cluster

if [ -e /etc/sysconfig/cluster ]; then
	. /etc/sysconfig/cluster
fi

# TO DO get chrootdir from cluster-lib.sh
# - test chrootdir/
# - fallback /comoonics
# - test /comoonics or die

if [ $chrootneeded -eq 0 ] && ! [ -e /var/comoonics/chrootpath ]; then
	if is_mounted /var/comoonics/chroot; then
	  echo /var/comoonics/chroot > /var/comoonics/chrootpath
	else
	  echo "Error: cannot find /var/comoonics/chrootpath" >&2
	  exit 1
	fi
fi

if [ $chrootneeded -eq 0 ]; then
  chrootdir=$(cat /var/comoonics/chrootpath)


  # Test for chrootdir
  if ! [ -e $chrootdir ]; then
	  echo "Error chroot dir $chrootdir does not exist."
	  exit 1
  fi
fi

while getopts vdhpVa: option ; do
	case "$option" in
	    V) # version
		echo "$0 Version '$Revision $'"
		exit 0
		;;
	    h) # help
		usage
		exit 0
		;;
		v) #verbose
		verbose=1
		;;
		d) #debug
		debug=1
		;;
		p) # print chroot path
		echo $chrootdir
		exit 0
		;;
		a) # action
		action=$OPTARG
		;;
	    *)
		echo "Error wrong option." >&2
		usage
		exit 1
		;;
	esac
done
shift $(($OPTIND - 1))

case "$action" in
	"")
	;;
	"update")
		[ $chrootneeded -eq 0 ] && update_chroot "$dep_filename_chroot" "$rpm_filename_chroot" "$filters_filename_chroot" "$(test ${pre_do:-0} -eq 1 && echo $pre_updatechroot_path)" "$(test ${post_do:-0} -eq 1 && echo $post_updatechroot_path)" "$chrootdir" "$(test ${use_cachedir:-1} && echo $cachedir)" "$(test ${use_cachedir:-1} && echo $indexfile_chroot)"
	;;
	"umount")
		[ $chrootneeded -eq 0 ] && umount_chroot
	;;
	"mount")
		[ $chrootneeded -eq 0 ] && mount_chroot
	;;
	"start_service")
		close_fds
		start_service_chroot $chrootdir $* &> /dev/null
	;;
	"stop_service_pid")
		stop_service_pid $1
	;;
	"stop_service_cmd")
		stop_service_cmd $1
	;;
	"status_service_pid")
		status_service_pid $1
	;;
	"status_service_cmd")
		status_service_cmd $1
		;;
	"mount_cdsl")
	    mount_cdsl $*
	    ;;
	"umount_cdsl")
	    umount_cdsl $*
	    ;;
	"status_cdsl")
	    status_cdsl $*
	    ;;
	"clean")
	    repository_clear
	    ;;
    "patch_files")
  	 	check_sharedroot $rootfs
     	sharedroot=$?
     	if  [ -n "$rootfs" ] && [ $sharedroot ]; then
  	      patch_files $*
      	fi
     	;;
	"unpatch_files")
  	 	check_sharedroot $rootfs
     	sharedroot=$?
     	if  [ -n "$rootfs" ] && [ $sharedroot ]; then
  	      unpatch_files $*
      	fi
     	;;
	 "createxfiles")
		createxfiles
		;;
	*)
		usage
		exit 1
esac
