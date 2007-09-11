#!/bin/bash

#****h* comoonics-bootimage/update_chroot.sh
#  NAME
#    update_chroot.sh
#    
#  DESCRIPTION
#*******
#
# $Id: manage_chroot.sh,v 1.2 2007-09-11 15:45:36 mark Exp $
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

logfile=/var/log/manage_chroot.log

#to be backward compatible
exec 3>> $logfile
exec 4>> $logfile
exec 5>> $logfile
exec 6>> $logfile
exec 7>> $logfile


# include libraries

if  ! [ -e $(dirname $0)/boot-scripts/etc/boot-lib.sh ]; then
  echo "Cannot find $(dirname $0)/boot-scripts/etc/boot-lib.sh"
  exit 1
fi
if ! [ -e $(dirname $0)/boot-scripts/etc/stdfs-lib.sh ]; then
  echo "Cannot find $(dirname $0)/boot-scripts/etc/stdfs-lib.sh"
  exit 1
fi
if ! [ -e $(dirname $0)/boot-scripts/etc/std-lib.sh ]; then
  echo "Cannot find $(dirname $0)/boot-scripts/etc/stdfs-lib.sh"
  exit 1
fi
if ! [ -e $(dirname $0)/boot-scripts/etc/chroot-lib.sh ]; then
  echo "Cannot find $(dirname $0)/boot-scripts/etc/chroot-lib.sh"
  exit 1
fi

. $(dirname $0)/boot-scripts/etc/boot-lib.sh
. $(dirname $0)/boot-scripts/etc/chroot-lib.sh
. $(dirname $0)/boot-scripts/etc/stdfs-lib.sh
. $(dirname $0)/boot-scripts/etc/std-lib.sh
. $(dirname $0)/boot-scripts/etc/defaults.sh
. $(dirname $0)/boot-scripts/etc/clusterfs-lib.sh
clutype=$(getCluType)
 if ! [ -e $(dirname $0)/boot-scripts/etc/$clutype-lib.sh ]; then
  echo "Cannot find $(dirname $0)/boot-scripts/etc/$clutype-lib.sh"
  exit 1
fi
. $(dirname $0)/boot-scripts/etc/$clutype-lib.sh

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

function umount_chroot() {
	for dir in $UMOUNTFS; do 
		umount $chrootdir/$dir
	done
}

function mount_chroot() {
	if ! mount | grep "$chrootdir/dev/" &> /dev/null; then
		mount --bind dev $chrootdir/dev
	fi
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

	files=( $(get_all_files_dependent $dep_filename $verbose | sort -u | grep -v "^.$" | grep -v "^..$") )
	rc=$?

	log "found ${#files[@]} files $(return_code $rc) "

	log "Copying files..."
	copy_filelist $chrootdir ${files[@]}

	log "copy files: $(return_code $rc)"
}

#include /etc/sysconfig/cluster

if [ -e /etc/sysconfig/cluster ]; then
	. /etc/sysconfig/cluster
fi

# TO DO get chrootdir from cluster-lib.sh
# - test chrootdir/
# - fallback /comoonics
# - test /comoonics or die

if ! [ -e /var/comoonics/chrootpath ]; then
	echo "Error: cannot find /var/comoonics/chrootpath"
	exit 1
fi

chrootdir=$(cat /var/comoonics/chrootpath)

# Test for chrootdir
if ! [ -e $chrootdir ]; then
	echo "Error chroot dir $chrootdir does not exist."
	exit 1
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
		echo "Error wrong option."
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
		update_chroot
	;;
	"umount")
		umount_chroot
	;;
	"mount")
		mount_chroot
	;;
	"start_service")
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
	*)
		usage
		exit 1
esac
