#!/bin/bash
#
# $Id: com-realhalt.sh,v 1.7 2008-06-11 15:59:35 marc Exp $
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
#****h* comoonics-bootimage/com-halt.sh
#  NAME
#    com-halt.sh
#    $Id: com-realhalt.sh,v 1.7 2008-06-11 15:59:35 marc Exp $
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
. $(dirname $0)/etc/hardware-lib.sh
. $(dirname $0)/etc/stdfs-lib.sh
. $(dirname $0)/etc/std-lib.sh
. $(dirname $0)/etc/defaults.sh
. $(dirname $0)/etc/clusterfs-lib.sh

distribution=$(getDistribution)
clutype=$(getCluType)
lvm_check $root
lvm_sup=$?

[ -e /etc/${distribution}/clusterfs-lib.sh ] && source /etc/${distribution}/clusterfs-lib.sh
[ -e /etc/${distribution}/${clutype}-lib.sh ] && source /etc/${distribution}/${clutype}-lib.sh

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
success
echo

step

rootfs=$(get_mounted_rootfs $COM_OLDROOT)

echo_local "com-realhalt: detected distribution: $distribution, clutype: $clutype, rootfs: $rootfs"
if [ "$rootfs" != "$clutype" ]; then
	. $(dirname $0)/etc/${rootfs}-lib.sh
	[ -e /etc/${distribution}/${rootfs}-lib.sh ] && source /etc/${distribution}/${rootfs}-lib.sh
fi


#nasty workaround for a bug that causes fenced to exit on sigstop sigcont
# see also rh bz#318571
if [ "$rootfs" = "gfs" ] && ! pidof fenced &> /dev/null; then
	fenced -c
	fence_tool join -w -c
	sleep 3
fi 

echo_local -n "Stopping processes in oldroot"
# killall in /mnt/oldroot
exec_local fuser -km -15 $COM_OLDROOT &> /dev/null
sleep 5
exec_local fuser -km -9 $COM_OLDROOT &> /dev/null
success
echo

step

echo_local -n "Umounting filesystems in oldroot"
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
exec_local /bin/umount $COM_OLDROOT "lock_dlm" $lvm_sup

step

clusterfs_services_stop
sleep 2

step

$*


