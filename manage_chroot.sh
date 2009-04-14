#!/bin/bash

#****h* comoonics-bootimage/update_chroot.sh
#  NAME
#    update_chroot.sh
#    
#  DESCRIPTION
#*******
#
# $Id: manage_chroot.sh,v 1.13 2009-04-14 15:07:11 marc Exp $
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


logfile=/var/log/manage_chroot.log

#to be backward compatible
exec 3>> $logfile
exec 4>> $logfile
exec 5>> $logfile
exec 6>> $logfile
exec 7>> $logfile

if [ -f /etc/sysconfig/comoonics-chroot ]; then
	source /etc/sysconfig/comoonics-chroot
fi

# include libraries

if ! [ -e $(dirname $0)/boot-scripts/etc/std-lib.sh ]; then
  echo "Cannot find $(dirname $0)/boot-scripts/etc/stdfs-lib.sh"
  exit 1
fi

source $(dirname $0)/boot-scripts/etc/std-lib.sh
sourceLibs $(dirname $0)/boot-scripts
repository_clear
sourceLibs $(dirname $0)/boot-scripts
clutype=$(repository_get_value clutype)
rootfs=$(get_mounted_rootfs)
repository_store_value cluster_conf /etc/cluster/cluster.conf
repository_store_value rootfs $rootfs
sourceRootfsLibs $(dirname $0)/boot-scripts
distribution=$(repository_get_value distribution)

if [ -z "$chrootneeded" ]; then
  clusterfs_chroot_needed init
  __default=$?
  chrootneeded=$(getParameter chroot $__default)
fi
initEnv

# dep_filename is the file where all dependent files are to be taken from
dep_filename=/etc/comoonics/bootimage-chroot/files.list
# rpm_filename is the file where all dependent files are to be taken from
rpm_filename=/etc/comoonics/bootimage-chroot/rpms.list
# cluster.conf
cluconf=/etc/cluster/cluster.conf
# filesystems
UMOUNTFS="/dev/pts /dev /proc /sys"

repository_store_value cluster_conf $cluconf
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
              /etc/comoonics/bootimage-chroot/files.list
     umount - umounts pts (needed for reboot
     start_service <commannd>    - starts a service in chroot
     stop_service_pid <pidfile>  - kills a service with pidfile in chroot
     stop_service_cmd <command>  - kills all services with name <command> TODO: in chroot
     status_service_pid <pidfile>  - returns status of service with pidfile in chroot
     status_service_cmd <command>  - returns status of service with name <command> TODO: in chroot
     mount_cdsl [<cdslpath>] [<cdsllocal>] - mounts the cdsl environment again
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
		umount $chrootdir/$dir & >/dev/null
	done
}

function mount_chroot() {
	local retc=0
	local subdir fstype device
	local i=
	local mounts=( "/dev/pts" "devpts" "none"  "/proc" "proc" "proc" "/sys" "sysfs" "sysfs" )
	if [ -z "$chrootdir" ]; then
		return 1
	fi
	# We end up in this clause only if we need a chroot but there is none yet.
	if [ -z "$chrootdir" ]; then
  		echo_local -n "Building comoonics chroot environment \"$chrootdir\" "
  		res=( $(build_chroot $(repository_get_value cluster_conf) $(repository_get_value nodename)) )
  		retc=$?
  		repository_store_value chroot_mount ${res[0]}
  		#FIXME: chroot_path should be the same as chrootdir but what to do here? How to decide?
  		repository_store_value chroot_path ${res[1]}
		echo_local "res: $res -> chroot_mount="$(repository_get_value chroot_mount)", chroot_path="$(repository_get_value chroot_path)
		return_code $retc 
	fi		
	echo_local -n "subdirs "
	while [ ${#mounts} -gt 0 ]; do
		subdir=${mounts[0]}
		fstype=${mount[1]}
		device=${mount[2]}
		mounts=( ${mounts[@]:3} )
		if ! is_mounted "${chrootdir}${subdir}" && ! is_mounted $(repository_get_value cdsl_local_dir)${chrootdir}${subdir}; then
			echo_local -n "..${subdir}.."
			mkdir -p $chrootdir${subdir} >/dev/null 2>&1
			mount -t $fstype $device $chrootdir${subdir}
		fi
	done
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

	if [ ! -e $dep_filename ]; then
		echo_local "dependency file $dep_filename does not exist"
		exit 1
	fi

	if [ ! -e $rpm_filename ]; then
		echo_local "rpm_filename $rpm_filename does not exist!"
	fi

	# extracting rpms
	if [ -n "$rpm_filename" ] && [ -e "$rpm_filename" ]; then
		echo_local -n "rpmfiles.."
  		extract_all_rpms $rpm_filename $chrootdir $rpm_dir $verbose
		[ $rc -eq 0 ] && rc=$?
	fi

	echo_local -n "dependent files "

	files=( $(get_all_files_dependent $dep_filename $verbose | sort -u | grep -v "^.$" | grep -v "^..$"| tr '&' '\n'))
	[ $rc -eq 0 ] && rc=$?
	echo_local -n "\"${#files[@]}\" .." 

	echo_local -n "copying... "
	copy_filelist $chrootdir ${files[@]}
	[ $rc -eq 0 ] && rc=$?
	return $rc
}

function mount_cdsl {
	local cdsl_path=$1
	local cdsl_local=$2

	local nodeid=$(getParameter nodeid $(cc_getdefaults nodeid))
	local newroot="/"
	
	[ -z "$cdsl_path" ] && cdsl_path=$(repository_get_value cdsl_prefix)
	[ -z "$cdsl_local" ] && cdsl_local=$(repository_get_value cdsl_local_dir)
	
	if [ -z "$nodeid" ]; then
		echo_local "Could not detect nodeid. Therefore I couldn't mount $cdsl_path" >&2
		exit 1
	fi
	clusterfs_mount_cdsl $newroot $cdsl_local $nodeid $cdsl_path	
}

function createxfiles {
	repository_store_value xtabfile /etc/xtab
	repository_store_value xrootfsfile /etc/xrootfs
	repository_store_value xkillallprocsfile /etc/xkillallprocs_file
	clusterfs_chroot_needed initrd
	__default=$?
	getParameter chrootneeded $__default &>/dev/null
	echo_local -n "Writing xtab.. "
	if [ $(repository_get_value chrootneeded) -eq 0 ]; then
  		create_xtab "$(repository_get_value xtabfile)" "$(repository_get_value cdsl_local_dir)" "$(repository_get_value chroot_mount)" 
	else  
  		create_xtab "$(repository_get_value xtabfile)" "$(repository_get_value cdsl_local_dir)"
	fi
	success

	echo_local -n "Writing xrootfs.. "
	create_xrootfs $(repository_get_value newroot)/$(repository_get_value xrootfsfile) $(repository_get_value rootfs)
	success

	echo_local -n "Writing xkillall_procs.. "
	create_xkillall_procs "$(repository_get_value newroot)/$(repository_get_value xkillallprocsfile)" "$(repository_get_value clutype)" "$(repository_get_value rootfs)"
	success
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
  # we patch all versions here
  for initscript in halt network netfs; do
	if ! grep "comoonics patch " /etc/init.d/$initscript > /dev/null; then
		echo -n "Patching $initscript ("
		for patchfile in $(ls -1 /opt/atix/comoonics-bootimage/patches/${initscript}*.patch | sort); do
			echo -n $(basename $patchfile)", "
			cd /etc/init.d/ && patch -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile || \
			echo "Failure patching $initscript with patch $patchfile" >&2
		done
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
  # we patch all versions here
  for initscript in halt network netfs; do
	if grep "comoonics patch " /etc/init.d/$initscript > /dev/null; then
		echo -n "Unpatching $initscript ("
		for patchfile in $(ls -1 /opt/atix/comoonics-bootimage/patches/${initscript}*.patch | sort -r); do
			echo -n $(basename $patchfile)", "
			cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile || \
			echo "Failure patching $initscript with patch $patchfile" >&2
		done
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
	echo "Error: cannot find /var/comoonics/chrootpath" >&2
	exit 1
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
		[ $chrootneeded -eq 0 ] && update_chroot
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
	"clean")
	    repository_clear
	    ;;
    "patch_files")
  	 	check_sharedroot $rootfs
     	sharedroot=$?
     	if  [ -n "$rootfs" ] && [ $sharedroot ]; then
  	      patch_files
      	fi
     	;;
	"unpatch_files")
  	 	check_sharedroot $rootfs
     	sharedroot=$?
     	if  [ -n "$rootfs" ] && [ $sharedroot ]; then
  	      unpatch_files
      	fi
     	;;
	 "createxfiles")
		createxfiles
		;;
	*)
		usage
		exit 1
esac
