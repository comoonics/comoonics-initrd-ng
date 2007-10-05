#!/bin/bash
#
# $Id: com-realhalt.sh,v 1.2 2007-10-05 13:36:25 mark Exp $
#
# @(#)$File$
#
# Copyright (c) 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# AG. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
#****h* comoonics-bootimage/com-halt.sh
#  NAME
#    com-halt.sh
#    $Id: com-realhalt.sh,v 1.2 2007-10-05 13:36:25 mark Exp $
#  DESCRIPTION
#    script called from <chrootpath>/com-halt.sh
#  USAGE
#    com-realhalt.sh [-s] haltcmd
#*******


function usage() {
	echo "$(basename $0) -v | -h | -r oldroot [-s] [-S] [-d] <reboot-cmd> "
	echo " -v:			show version"
	echo " -h:  		show this"
	echo " -r oldroot	set oldroot mountpoint"
	echo " -s 			step-mode"
	echo " -S			dstep-mode"
	echo " -d			debug"
	echo " <reboot-cmd> command to reboot"
}

logfile=/var/log/com-realhalt.log

#to be backward compatible
exec 3>> $logfile
exec 4>> $logfile
exec 5>> $logfile
exec 6>> $logfile
exec 7>> $logfile


# include libraries

if  ! [ -e $(dirname $0)/etc/boot-lib.sh ]; then
  echo "Cannot find $(dirname $0)/etc/boot-lib.sh"
  exit 1
fi
if ! [ -e $(dirname $0)/etc/stdfs-lib.sh ]; then
  echo "Cannot find $(dirname $0)/etc/stdfs-lib.sh"
  exit 1
fi
if ! [ -e $(dirname $0)/etc/std-lib.sh ]; then
  echo "Cannot find $(dirname $0)/etc/stdfs-lib.sh"
  exit 1
fi
if ! [ -e $(dirname $0)/etc/chroot-lib.sh ]; then
  echo "Cannot find $(dirname $0)/etc/chroot-lib.sh"
  exit 1
fi

. $(dirname $0)/etc/boot-lib.sh
. $(dirname $0)/etc/chroot-lib.sh
. $(dirname $0)/etc/stdfs-lib.sh
. $(dirname $0)/etc/std-lib.sh
. $(dirname $0)/etc/defaults.sh
. $(dirname $0)/etc/clusterfs-lib.sh

distribution=$(getDistribution)
clutype=$(getCluType)
rootfs=$(getRootFS)

[ -e /etc/${distribution}/clusterfs-lib.sh ] && source /etc/${distribution}/clusterfs-lib.sh
[ -e /etc/${distribution}/${clutype}-lib.sh ] && source /etc/${distribution}/${clutype}-lib.sh


if [ "$rootfs" != "$clutype" ]; then
	. $(dirname $0)/etc/${rootfs}-lib.sh
	[ -e /etc/${distribution}/${rootfs}-lib.sh ] && source /etc/${distribution}/${rootfs}-lib.sh
fi


if ! [ -e $(dirname $0)/etc/$clutype-lib.sh ]; then
  echo "Cannot find $(dirname $0)/etc/$clutype-lib.sh"
  exit 1
fi
. $(dirname $0)/etc/$clutype-lib.sh

initEnv

while getopts VdhsSr: option ; do
	case "$option" in
	    V) # version
		echo "$0 Version '$Revision $'"
		exit 0
		;;
		v) #verbose
		verbose=1
		;;
		d) #debug
		debug=1
		;;
		r) 
		COM_OLDROOT=$OPTARG
		;;
		h)
		usage
		exit 0
		;;
		s) 
		stepmode=1
		;;
		S) 
		dstepmode=1
		;;
	    *)
		echo "Error wrong option."
		usage
		exit 1
		;;
	esac
done
shift $(($OPTIND - 1))

if [ -z "$COM_OLDROOT" ]; then
	usage
	exit 1
fi


# Verify that chroot environment is in a good state
# TODO remount /sys and /sys/kernel/config filesystems rw
echo_local -n "Preparing chroot" 
/bin/mount -t proc proc /proc &> /dev/null
/bin/mount -t sysfs none /sys &> /dev/null
/bin/mount -t configfs none /sys/kernel/config &> /dev/null
/bin/ln -sf /proc/mounts /etc/mtab
/bin/true
return_code

step

#nasty workaround for a bug that causes fenced to exit on sigstop sigcont
# see also rh bz#318571
if ! pidof fenced &> /dev/null; then
	fenced -c
	fence_tool join -w -c
	sleep 3
fi 

echo_local -n "Stopping processes in oldroot"
# killall in /mnt/oldroot
exec_local fuser -km -15 $COM_OLDROOT &> /dev/null
sleep 5
exec_local fuser -km -9 $COM_OLDROOT &> /dev/null
return_code

step

echo_local -n "Umounting filsystems in oldroot"
exec_local mkdir /dev2
exec_local "mount --move $COM_OLDROOT/dev /dev2"
for fs in sys proc cdsl.local; do
	exec_local "umount $COM_OLDROOT/$fs" 
done
return_code

step

echo_local -n "Restarting init process in chroot"
# restart init
restart_init
return_code

step

echo_local -n "Umounting oldroot"
exec_local /bin/umount $COM_OLDROOT 

step

clusterfs_services_stop
sleep 2

step

$*






