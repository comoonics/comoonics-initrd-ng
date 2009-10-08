#!/bin/bash
#
# $Id: com-realhalt.sh,v 1.12 2009-10-08 08:05:04 marc Exp $
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
#    $Id: com-realhalt.sh,v 1.12 2009-10-08 08:05:04 marc Exp $
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
#exec 3>> $logfile
#exec 4>> $logfile
#exec 5>> $logfile
#exec 6>> $logfile
#exec 7>> $logfile


# include libraries
predir=$(dirname $0)
source ${predir}/etc/std-lib.sh
sourceLibs ${predir}
lvm_check $root
lvm_sup=$?

initEnv

version='$Revision $'

while getopts VdhsSr: option ; do
	case "$option" in
	    V) # version
		echo "$0 Version $version"
		exit 0
		;;
		v) #verbose
		   verbose=1
		   repository_store_value verbose 1
		   ;;
		d) #debug
		   repository_store_value debug 1
		   ;;
		r) 
		COM_OLDROOT=$OPTARG
		;;
		h)
		usage
		exit 0
		;;
		s) 
		   repository_store_value step 1
		   ;;
		S) 
		   repository_store_value dstep 1
		   ;;
	    *)
		echo "Error wrong option."
		usage
		exit 1
		;;
	esac
done
shift $(($OPTIND - 1))
cmd=$*
repository_store_value haltcmd "$cmd"

if [ -z "$COM_OLDROOT" ]; then
	usage
	exit 1
fi

PYTHONPATH=$(python -c 'import os; import sys; print (os.path.join("/usr", "lib", "python%u.%u" %(int(sys.version[0]), int(sys.version[2])), "site-packages"))')
export PYTHONPATH

echo_local "Starting ATIX exitrd"
echo_local "Comoonics-Release"
release=$(cat ${predir}/etc/comoonics-release)
echo_local "$release"
echo_local 'Internal Version $Revision: 1.12 $ $Date: 2009-10-08 08:05:04 $'
echo_local_debug "Calling cmd "$(repository_get_value haltcmd)
#echo_local "Builddate: "$(date)

repository_store_value oldroot $COM_OLDROOT

# Verify that chroot environment is in a good state
# TODO remount /sys and /sys/kernel/config filesystems rw
echo_local -n "Preparing chroot" 
/bin/mount -t proc proc /proc &> /dev/null
/bin/mount -t sysfs none /sys &> /dev/null
/bin/mount -t configfs none /sys/kernel/config &> /dev/null
/bin/ln -sf /proc/mounts /etc/mtab
[ -f $(repository_get_value oldroot)/dev/initctl ] && [ -f /dev/initctl ] || cp -a $(repository_get_value oldroot)/dev/initctl /dev/initctl
success

step "halt: Chroot prepared" "halt_chrootprepared"

sourceRootfsLibs ${predir}
clutype=$(repository_get_value clutype)
distribution=$(repository_get_value distribution)
rootfs=$(repository_get_value rootfs)
echo_local "com-realhalt: detected distribution: $distribution, clutype: $clutype, rootfs: $rootfs"

#nasty workaround for a bug that causes fenced to exit on sigstop sigcont
# see also rh bz#318571
if [ "$rootfs" = "gfs" ] && ! pidof fenced &> /dev/null; then
	fenced -c
	fence_tool join -w -c
	sleep 3
fi 

echo_local -n "Restarting init process in chroot"
# restart init
restart_init
return_code

step "halt: Restarted init process in chroot" "halt_restartinit"

echo_local -n "Moving dev filesystem"
exec_local mkdir /dev2
if is_mounted $(repository_get_value oldroot)/dev/pts; then
   _filesystem=/dev/pts
   fuser -m $(repository_get_value oldroot)/$_filesystem &> /dev/null &&
   fuser -km -15 $(repository_get_value oldroot)/$_filesystem &> /dev/null
   sleep 2
   fuser -m $(repository_get_value oldroot)/$_filesystem &> /dev/null &&
   fuser -km -9 $(repository_get_value oldroot)/$_filesystem &> /dev/null
#   success
#   echo_local -n "Umounting $_filesystem"
   exec_local "umount $(repository_get_value oldroot)/$_filesystem"
fi
is_mounted $(repository_get_value oldroot)/dev && exec_local "mount --move $(repository_get_value oldroot)/dev /dev2" &&
is_mounted /dev/pts || exec_local "mount -t devpts none /dev/pts" &&
return_code
step "Moved /dev filesystem" "movedevfs"

rc=0
echo_local -n "Umounting filesystems in oldroot ("$(get_dep_filesystems $(repository_get_value oldroot))")"
for _filesystem in $(get_dep_filesystems $(repository_get_value oldroot)); do
#   echo_local_debug "Processes running in oldroot $_filesystem"
#   exec_local_debug fuser -mv $_filesystem

#   echo_local -n "Stopping processes in $_filesystem"
   # killall in /mnt/oldroot
   fuser -m $(repository_get_value oldroot)/$_filesystem &> /dev/null &&
   fuser -km -15 $(repository_get_value oldroot)/$_filesystem &> /dev/null
   sleep 2
   fuser -m $(repository_get_value oldroot)/$_filesystem &> /dev/null &&
   fuser -km -9 $(repository_get_value oldroot)/$_filesystem &> /dev/null
#   success
   echo_local -n "Umounting $_filesystem"
   exec_local "umount $_filesystem"
   [ $return_c -ne 1 ] && rc=$return_c
   
#   return_code 
done
return_code $rc

step "halt: Successfully umounted filesystem in oldroot" "halt_umountoldroot"

_filesystem=$(repository_get_value oldroot)
echo_local_debug "Processes running in oldroot $_filesystem"
exec_local_debug fuser -mv $_filesystem

echo_local -n "Stopping processes in $_filesystem"
# killall in /mnt/oldroot
exec_local fuser -km -15 $(repository_get_value oldroot) &> /dev/null
sleep 5
exec_local fuser -km -9 $(repository_get_value oldroot) &> /dev/null
success
step "halt: Successfully stopped processes running in oldroot" "halt_stopoldroot"

echo_local -n "Umounting oldroot $_filesystem"
exec_local /bin/umount $_filesystem
return_code
step "halt: Umounting oldroot" "halt_umountoldroot"

clusterfs_services_stop

sleep 2

step "halt: Stopped clusterfs services" "halt_stopclusterfs"

echo_local "Finally calling "$(repository_get_value haltcmd) 
$cmd

#####################
# $Log: com-realhalt.sh,v $
# Revision 1.12  2009-10-08 08:05:04  marc
# oldroot in repo
# and bugfix when umounting /dev/pts
#
# Revision 1.11  2009/10/07 11:55:10  marc
# - Changed the halt process so that first every process accessing an fs is killed the the fs is umounted
# - Cosmetics and usability changes
#
# Revision 1.10  2009/09/28 13:09:59  marc
# - Implemented new way to also use com-realhalt as halt.local either in /sbin or /etc/init.d dependent on distribution
# - debugging and stepmode autodetection
#