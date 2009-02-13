#!/bin/bash

#****h* comoonics-bootimage/update_chroot.sh
#  NAME
#    update_chroot.sh
#    
#  DESCRIPTION
#*******
#
# $Id: manage_chroot.sh,v 1.11 2009-02-13 08:44:13 mark Exp $
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

clusterfs_chroot_needed init
__default=$?
chrootneeded=$(getParameter chroot $__default)

initEnv

# dep_filename is the file where all dependent files are to be taken from
dep_filename=/etc/comoonics/bootimage-chroot/files.list
# rpm_filename is the file where all dependent files are to be taken from
rpm_filename=/etc/comoonics/bootimage-chroot/rpms.list
# cluster.conf
cluconf=/etc/cluster/cluster.conf
# filesystems
UMOUNTFS="/dev/pts /dev /proc /sys"


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
		echo_local $*
	else 
		echo_out $*
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
	if ! mount | grep "$chrootdir/dev/pts" &> /dev/null; then
		mount -t devpts none $chrootdir/dev/pts
	fi
	if ! mount | grep "$chrootdir/proc" &> /dev/null; then
		mount -t proc proc $chrootdir/proc
	fi
	if ! mount | grep "$chrootdir/sys" &> /dev/null; then
		mount -t sysfs none $chrootdir/sys
	fi
	
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
	log "starting update_chroot"

	if [ ! -e $dep_filename ]; then
		log "dependency file $dep_filename does not exist"
		exit 1
	fi

	if [ ! -e $rpm_filename ]; then
		log "rpm_filename $rpm_filename does not exist!"
	fi

	# extracting rpms
	if [ -n "$rpm_filename" ] && [ -e "$rpm_filename" ]; then
  		extract_all_rpms $rpm_filename $chrootdir $rpm_dir $verbose
  		rc=$?
  		log "Extracted rpms: $(return_code $rc)" 
	fi

	log "Retreiving dependent files"

	files=( $(get_all_files_dependent $dep_filename $verbose | sort -u | grep -v "^.$" | grep -v "^..$"| tr '&' '\n'))
	rc=$?

	log "found ${#files[@]} files $(return_code $rc) "

	log "Copying files..."
	copy_filelist $chrootdir ${files[@]}

	log "copy files: $(return_code $rc)"
}

function mount_cdsl {
	local cdsl_path=$1
	local cdsl_local=$2

	local nodeid=$(getParameter nodeid $(cc_getdefaults nodeid))
	local newroot="/"
	
	[ -z "$cdsl_path" ] && cdsl_path=$cdsl_prefix
	[ -z "$cdsl_local" ] && cdsl_local=$cdsl_local_dir 
	
	clusterfs_mount_cdsl $newroot $cdsl_local $nodeid $cdsl_path	
}

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
	*)
		usage
		exit 1
esac
