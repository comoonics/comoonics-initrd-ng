#!/bin/bash
#
# $Id: com-realhalt.sh,v 1.18 2011-02-11 15:09:53 marc Exp $
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
#    $Id: com-realhalt.sh,v 1.18 2011-02-11 15:09:53 marc Exp $
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

initHaltProcess

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
echo_local 'Internal Version $Revision: 1.18 $ $Date: 2011-02-11 15:09:53 $'
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
[ -e $(repository_get_value oldroot)/dev/initctl ] && [ -e /dev/initctl ] || cp -a $(repository_get_value oldroot)/dev/initctl /dev/initctl
[ -e $(repository_get_value oldroot)/dev/console ] && [ -e /dev/console ] || cp -a $(repository_get_value oldroot)/dev/console /dev/console
success

step "halt: Chroot prepared" "halt_chrootprepared"

sourceRootfsLibs ${predir}
clutype=$(repository_get_value clutype)
distribution=$(repository_get_value distribution)
rootfs=$(repository_get_value rootfs)
echo_local "com-realhalt: detected distribution: $distribution, clutype: $clutype, rootfs: $rootfs"

#nasty workaround for a bug that causes fenced to exit on sigstop sigcont
# see also rh bz#318571
#if [ "$rootfs" = "gfs" ] && ! pidof fenced &> /dev/null; then
#	fenced -c
#	fence_tool join -w -c
#	sleep 3
#fi 

echo_local -n "Restarting init process in chroot"
# restart init
restart_init
return_code

step "halt: Restarted init process in chroot" "halt_restartinit"

echo_local -n "Moving dev filesystem"
exec_local mkdir /dev2
if is_mounted $(repository_get_value oldroot)/dev/pts; then
   exec_local umount_filesystem $(repository_get_value oldroot)/dev/pts 1
fi
is_mounted $(repository_get_value oldroot)/dev && exec_local "mount --move $(repository_get_value oldroot)/dev /dev2" &&
[ -d /dev/pts ] || mkdir /dev/pts
is_mounted /dev/pts || exec_local "mount -t devpts none /dev/pts" &&
return_code
step "Moved /dev filesystem" "movedevfs"

filesystems="$(get_dep_filesystems $(repository_get_value oldroot)/sys) $(get_dep_filesystems $(repository_get_value oldroot)/proc) $(repository_get_value oldroot)/sys $(repository_get_value oldroot)/proc"
if [ -n "$filesystems" ]; then
  rc=0
  echo_local "Umounting filesystems in oldroot ("$filesystems")"
  for _filesystem in $filesystems; do
    if is_mounted $_filesystem; then 
      echo_local -n "Umounting $_filesystem"
      exec_local umount_filesystem $_filesystem
      return_code $rc
      [ $return_c -ne 1 ] && rc=$return_c
    fi
  done
fi
filesystems=$(get_dep_filesystems $(repository_get_value oldroot))	
if [ -n "$filesystems" ]; then
  rc=0
  echo_local "Umounting filesystems in oldroot ("$filesystems")"
  for _filesystem in $filesystems; do
    if is_mounted $_filesystem; then 
      echo_local -n "Umounting $_filesystem"
      exec_local umount_filesystem $_filesystem 1
      return_code $rc
      [ $return_c -ne 1 ] && rc=$return_c
    fi
  done
fi
unset filesystems rc

step "halt: Successfully umounted filesystem in oldroot" "halt_umountoldfs"

_filesystem=$(repository_get_value oldroot)
echo_local -n "Umounting oldroot $_filesystem"
exec_local umount_filesystem  $_filesystem 1
return_code
step "halt: Umounting oldroot" "halt_umountoldroot"

lvm_check $(repository_get_value root)
lvm_sup=$?
clusterfs_services_stop "" "" "$lvm_sup"
step "halt: Stopped clusterfs services" "halt_stopclusterfs"

sleep 2

echo_local "Finally calling "$(repository_get_value haltcmd) 
$cmd
