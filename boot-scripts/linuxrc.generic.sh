#!/bin/bash
#
# $Id: linuxrc.generic.sh,v 1.56 2008-05-10 19:42:33 marc Exp $
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
#****h* comoonics-bootimage/linuxrc.generic.sh
#  NAME
#    linuxrc
#    $Id: linuxrc.generic.sh,v 1.56 2008-05-10 19:42:33 marc Exp $
#  DESCRIPTION
#    The first script called by the initrd.
#*******

#****b* comoonics-bootimage/linuxrc/com-stepmode
#  NAME
#    com-stepmode
#  DESCRIPTION
#   If set it asks for <return> after every step
#***** com-step

#****b* comoonics-bootimage/linuxrc/com-debug
#  NAME
#    com-debug
#  DESCRIPTION
#    If set debug info is output
#***** com-debug

#****f* linuxrc.generic.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main()
#  MODIFICATION HISTORY
#  IDEAS
#
#  SOURCE
#
# initstuff is done in here

. /etc/sysconfig/comoonics

. /etc/chroot-lib.sh
. /etc/boot-lib.sh
. /etc/hardware-lib.sh
. /etc/network-lib.sh
. /etc/clusterfs-lib.sh
. /etc/std-lib.sh
. /etc/stdfs-lib.sh
. /etc/defaults.sh
. /etc/xen-lib.sh
[ -e /etc/iscsi-lib.sh ] && source /etc/iscsi-lib.sh
[ -e /etc/drbd-lib.sh ] && source /etc/drbd-lib.sh

clutype=$(getCluType)
. /etc/${clutype}-lib.sh

# including all distribution dependent files
distribution=$(getDistribution)
[ -e /etc/${distribution}/boot-lib.sh ] && source /etc/${distribution}/boot-lib.sh
[ -e /etc/${distribution}/hardware-lib.sh ] && source /etc/${distribution}/hardware-lib.sh
[ -e /etc/${distribution}/network-lib.sh ] && source /etc/${distribution}/network-lib.sh
[ -e /etc/${distribution}/clusterfs-lib.sh ] && source /etc/${distribution}/clusterfs-lib.sh
[ -e /etc/${distribution}/${clutype}-lib.sh ] && source /etc/${distribution}/${clutype}-lib.sh
[ -e /etc/${distribution}/xen-lib.sh ] && source /etc/${distribution}/xen-lib.sh
[ -e /etc/${distribution}/iscsi-lib.sh ] && source /etc/${distribution}/iscsi-lib.sh
[ -e /etc/${distribution}/drbd-lib.sh ] && source /etc/${distribution}/drbd-lib.sh

echo_local "Starting ATIX initrd"
echo_local "Comoonics-Release"
release=$(cat /etc/comoonics-release)
echo_local "$release"
echo_local 'Internal Version $Revision: 1.56 $ $Date: 2008-05-10 19:42:33 $'
echo_local "Builddate: "$(date)

initBootProcess

x=`cat /proc/version`;
KERNEL_VERSION=`expr "$x" : 'Linux version \([^ ]*\)'`
echo_local "Kernel-version: ${KERNEL_VERSION}"
if [ "${KERNEL_VERSION:0:3}" = "2.4" ]; then
  modules_conf="/etc/modules.conf"
else
  modules_conf="/etc/modprobe.conf"
fi

# boot parameters
echo_local -n "Scanning for Bootparameters..."
bootparms=$(getBootParameters)
return_code=$?
debug=$(getParm ${bootparms} 1)
stepmode=$(getParm ${bootparms} 2)
mount_opts=$(getParm ${bootparms} 3)
tmpfix=$(getParm ${bootparms} 4)
scsifailover=$(getParm ${bootparms} 5)
dstepmode=$(getParm ${bootparms} 6)
nousb=$(getParm ${bootparms} 7)
return_code 0

# network parameters
echo_local -n "Scanning for network parameters..."
netparms=$(getNetParameters)
ipConfig=$(getParm ${netparms} 1)
return_code 0

# clusterfs parameters
echo_local -n "Scanning for clusterfs parameters..."
cfsparams=$(getClusterFSParameters)
rootsource=$(getParm ${cfsparams} 1)
root=$(getParm ${cfsparams} 2)
lockmethod=$(getParm ${cfsparams} 3)
sourceserver=$(getParm ${cfsparams} 4)
quorumack=$(getParm ${cfsparams} 5)
nodeid=$(getParm ${cfsparams} 6)
nodename=$(getParm ${cfsparams} 7)
rootfs=$(getParm ${cfsparams} 8)
return_code 0

check_cmd_params $*

echo_local_debug "*****************************"
echo_local_debug "Debug: $debug"
echo_local_debug "Stepmode: $stepmode"
echo_local_debug "Debug-stepmode: $dstepmode"
echo_local_debug "Clutype: $clutype"
echo_local_debug "mount_opts: $mount_opts"
echo_local_debug "tmpfix: $tmpfix"
echo_local_debug "ip: $ipConfig"
echo_local_debug "rootsource: $rootsource"
echo_local_debug "root: $root"
echo_local_debug "lockmethod: $lockmethod"
echo_local_debug "sourceserver: $sourceserver"
echo_local_debug "scsifailover: $scsifailover"
echo_local_debug "quorumack: $quorumack"
echo_local_debug "nodeid: $nodeid"
echo_local_debug "nodename: $nodename"
echo_local_debug "rootfs: $rootfs"
echo_local_debug "clutype: $clutype"
echo_local_debug "nousb: " $nousb
echo_local_debug "*****************************"

echo_local_debug "*****************************"
# step
echo_local -en $"\t\tPress 'I' to enter interactive startup."
echo_local

{
 sleep 2
 hardware_detect

 echo_local "Starting network configuration for lo0"
 exec_local nicUp lo
 return_code
 auto_netconfig
} &
read -n1 -t5 confirm
if [ "$confirm" = "i" ]; then
  echo_local -e "\t\tInteractivemode recognized. Switching step_mode to on"
  stepmode=1
fi
wait

step "Inialization started"

# cluster_conf is set in clusterfs-lib.sh or overwritten in gfs-lib.sh
# FIXME: This overrides boot setting !
# BUG: bz#31

cfsparams=( $(clusterfs_config $cluster_conf $ipConfig $nodeid $nodename ) )
echo "cfsparams: $cfsparams"
nodeid=${cfsparams[0]}
nodename=${cfsparams[1]}
rootvolume=${cfsparams[2]}
_mount_opts=${cfsparams[3]}
scsifailover=${cfsparams[4]}
rootfs=${cfsparams[5]}
_rootsource=${cfsparams[6]}
_ipConfig=${cfsparams[@]:7}
[ -n "$_ipConfig" ] && ( [ -z "$ipConfig" ] || [ "$ipConfig" = "cluster" ] ) && ipConfig=$_ipConfig
[ -n "$_mount_opts" ] && [ -z "$mount_opts" ] && mount_opts=$_mount_opts
[ -z "$mount_opts" ] && mount_opts="defaults" 
[ -z "$scsifailover" ] && scsifailover="driver"
[ -z "$root" ] || [ "$root" = "/dev/ram0" ] && root=$rootvolume
[ -z "$rootsource" ] && rootsource=$_rootsource
[ -z "$rootsource" ] && rootsource="scsi"

echo_local_debug "*****************************"
echo_local_debug "nodeid: $nodeid"
echo_local_debug "nodename: $nodename"
echo_local_debug "rootvolume: $rootvolume"
echo_local_debug "scsifailover: $scsifailover"
echo_local_debug "rootfs: $rootfs"
echo_local_debug "mountopts: $mount_opts"
echo_local_debug "rootsource: $rootsource"
echo_local_debug "ipConfig: $ipConfig"
echo_local_debug "*****************************"

step "Parameter loaded"

if [ "$clutype" != "$rootfs" ]; then
	source /etc/${rootfs}-lib.sh
	[ -e /etc/${distribution}/${rootfs}-lib.sh ] && source /etc/${distribution}/${rootfs}-lib.sh
fi

xen_domx_detect
if [ $? -ne 0 ] || [ -z "$nousb" ]; then
  echo_local -n "Loading USB Modules.."
  exec_local usbLoad
  return_code
  [ -e /proc/bus/usb/devices ] && stabilized --type=hash --interval=300 /proc/bus/usb/devices
fi

netdevs=""
for ipconfig in $ipConfig; do
  dev=$(getPosFromIPString 6, $ipconfig)

#  echo_local "Device $dev"
  # Special case for bonding
  { echo "$dev"| grep "^bond" && grep -v "alias $dev" $modules_conf; } >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    # Think about bonding parameters.
    # Multi load of bonding driver possible?
    echo_local -n "Patching $modules_conf for bonding "
    echo "alias $dev bonding" >> $modules_conf
    return_code $?
    depmod -a >/dev/null 2>&1
  fi

  nicConfig $ipconfig

  echo_local -n "Powering up $dev.."
  exec_local nicUp $dev >/dev/null 2>&1
  return_code $?
  netdevs="$netdevs $dev"
done

step "Network configuration started"


dm_start
scsi_start $scsifailover

# start iscsi if apropriate
isISCSIRootsource $rootsource
if [ $? -eq 0 ]; then
	loadISCSI
	startISCSI $rootsource $nodename
fi

# loads kernel modules for cluster stack
# TODO: - rename to clusterfs_kernel_load
#       - add cluster_kernel_load
#       - move below ?
# 1.3.+ ?
clusterfs_load $lockmethod
return_code

step "Hardware detected, modules loaded"

echo_local -n "Starting udev "
exec_local udev_start
return_code

if [ "$scsifailover" = "mapper" ] || [ "$scsifailover" = "devicemapper" ]; then
  dm_mp_start
fi
[ -e /proc/scsi/scsi ] && stabilized --type=hash --interval=600 /proc/scsi/scsi
step "UDEV started"

lvm_check $root
lvm_sup=$?
if [ "$lvm_sup" -eq 0 ]; then
	lvm_start
	step "LVM subsystem started"
fi


# TODO:
# - mount chroot from either
#   - local disk defined in /etc/sysconfig/comoonics-chroot
#   - cluster.conf
#   - ramdisk
# - create chroot environment in /comoonics by
#   - copy everything from / except /lib/modules
#   - mount --bind /dev /comoonics/dev
#   - mount -t proc proc /comoonics/proc ?
#   - mount -t sysfs none /comoonics/sys

# TODO:
# Put all things into a library function

echo_local -n "Building comoonics chroot environment"
res=( $(build_chroot $cluster_conf $nodename) )
chroot_mount=${res[0]}
chroot_path=${res[1]}
return_code $?

echo_local_debug "res: $res -> chroot_mount=$chroot_mount, chroot_path=$chroot_path"


step "chroot environment created"

cc_auto_hosts $cluster_conf
cc_auto_syslogconfig $cluster_conf $nodename
start_service /sbin/syslogd no_chroot -m 0

# start syslog in $chroot_path
# but only if /dev is not the same inode as $chroot_path /dev
if ! is_same_inode /dev $chroot_path/dev; then
	cc_auto_syslogconfig $cluster_conf $nodename $chroot_path no
	start_service_chroot $chroot_path /sbin/syslogd -m 0
fi

step "Syslog services started"

# WARNING!
# DRBD initialization doesn't seem possible before this point!
# start drbd if appropriate
isDRBDRootsource $rootsource
if [ $? -eq 0 ]; then
	loadDRBD
	startDRBD $rootsource $nodename
fi

if [ -z "$quorumack" ]; then
  echo_local -n "Checking for all nodes to be available"
  exec_local cluster_checkhosts_alive
  return_code
  if [ $return_c -ne 0 ]; then
  	echo_local ""
  	echo_local ""
  	echo_local "I couldn't talk to the required number of cluster nodes."
	echo_local "To avoid data inconsitency caused by cluster partitioning (split brain) "
	echo_local "the next step has to be acknowledged manually."
	echo_local ""
	echo_local "If you are sure, that the cluster is in a consistent state, please type YES."
	echo_local ""
	echo_local ""
	echo_local "CAUTION: !!! If you are unsure about all other nodes state, check first."
	echo_local "         Otherwise you'll risk split brain with data inconsistency !!!"

	confirm="XXX"
	if [ $debug ]; then set -x; fi
	until [ $confirm == "YES" ] || [ $confirm == "NO" ]; do
  		echo_local "USER INPUT: (YES|NO): "
  		read confirm
  		echo_local_debug "confirm: $confirm"
  		if [ $confirm == "NO" ]; then
  			echo_local "Cluster not acknowledged. Falling back to shell"
  			exit_linuxrc 1
  		fi
  	done
  	if [ $debug ]; then set +x; fi
  fi
fi

xen_domx_detect
if  [ $? -ne 0 ]; then
  setHWClock
fi

clusterfs_services_start $chroot_path "$lockmethod" "$lvm_sup"

if [ $return_c -ne 0 ]; then
   echo_local "Could not start all cluster services. Exiting"
   exit_linuxrc 1
fi
sleep 5

step "Cluster services started"

clusterfs_mount $rootfs $root $newroot $mount_opts 3 5
if [ $return_c -ne 0 ]; then
   echo_local "Could not mount cluster filesystem $rootfs $root to $mount_point. Exiting ($mount_opts)"
   exit_linuxrc 1
fi

step "RootFS mounted"

clusterfs_mount_cdsl $newroot $cdsl_local_dir $nodeid $cdsl_prefix
if [ $return_c -ne 0 ]; then
   echo_local "Could not mount cdsl $cdsl_local_dir to ${cdsl_prefix}/$nodeid. Exiting"
   exit_linuxrc 1
fi

step "CDSL tree mounted"

#if [ -n "$debug" ]; then set -x; fi
#TODO clean up method
#copy_relevant_files $cdsl_local_dir $newroot $netdevs
#if [ -n "$debug" ]; then set +x; fi
step


# TODO:
# remove tmpfix as this is replaced with /comoonics
if [ -n "$tmpfix" ]; then
  echo_local -n "Setting up tmp..."
  exec_local createTemp /dev/ram1
  return_code
fi


echo_local -n "Mounting the device file system"
#TODO
# try an exec_local mount --move /dev $newroot/dev
exec_local mount --move /dev $newroot/dev
_error=$?
exec_local cp -a $newroot/dev/console /dev/
#exec_local mount --bind /dev $newroot/dev
return_code $_error

echo_local -n "Copying logfile to $newroot/${bootlog}..."
exec_local cp -f ${bootlog} ${newroot}/${bootlog} || cp -f ${bootlog} ${newroot}/$(basename $bootlog)
if [ -f ${newroot}/$bootlog ]; then
  bootlog=${newroot}/$bootlog
else
  bootlog=${newroot}/$(basename $bootlog)
fi
return_code_warning
exec 3>> $bootlog
exec 4>> $bootlog
step "Logfiles copied"

# FIXME: Remove line
#bootlog="/var/log/comoonics-boot.log"

#TODO: remove lines as syslog can will stay in /comoonics
echo_local -n "Stopping syslogd..."
exec_local stop_service "syslogd" / &&
return_code

echo_local -n "Moving chroot environment to $newroot"
move_chroot $chroot_mount $newroot/$chroot_mount
return_code

echo_local -n "Writing information ..."
exec_local mkdir -p $newroot/var/comoonics
echo $chroot_path > $newroot/var/comoonics/chrootpath
return_code

echo_local -n "cleaning up initrd ..."
exec_local clean_initrd
success
echo

#TODO umount $newroot/proc again
echo_local -n "start services in newroot ..."
exec_local prepare_newroot $newroot
exec_local clusterfs_services_restart_newroot $newroot "$lockmethod" "$lvm_sup"
return_code $?

step "Initialization completed."

echo_local "Starting init-process ($init_cmd)..."
exit_linuxrc 0 "$init_cmd" "$newroot"

#********** main

###############
# $Log: linuxrc.generic.sh,v $
# Revision 1.56  2008-05-10 19:42:33  marc
# - Implemened RFE#218 generating right hosts also with using dhcp.
#
# Revision 1.55  2008/03/18 17:41:52  marc
# - fixed bug for not detecting failover in all cases.
# - Technology preview for drbd added.
#
# Revision 1.54  2008/01/24 15:25:21  marc
# fixed a syntax error.
#
# Revision 1.53  2008/01/24 13:26:12  marc
# - BUG#179 xen detection will not work with RHEL4 guest
# - BUG#178 nousb parameter can be specified
# - rewrote part of iscsi
#
# Revision 1.52  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.51  2007/10/18 08:04:38  mark
# fixes bug #144
#
# Revision 1.50  2007/10/16 08:02:41  marc
# - added get_rootsource
# - fixed BUG 142
# - lvm switch support
#
# Revision 1.49  2007/10/10 22:48:08  mark
# fixes BZ139
#
# Revision 1.48  2007/10/10 15:09:48  mark
# move usbstart out of for-loop
#
# Revision 1.47  2007/10/10 12:23:27  mark
# added syslog to chroot
#
# Revision 1.46  2007/10/10 11:05:22  marc
# readded inclusion of iscsi-lib if available
#
# Revision 1.45  2007/10/09 16:48:33  mark
# restart some cluster services in newroot (clvmd)
#
# Revision 1.44  2007/10/09 14:24:27  marc
# usbLoad fixed and more stabilized
#
# Revision 1.43  2007/10/08 16:13:55  mark
# source distrodependent boot-lib.sh
#
# Revision 1.42  2007/10/05 10:07:56  marc
# - added xen-support
#
# Revision 1.41  2007/10/02 12:16:02  marc
# - cosmetic changes to prevent unnecesarry ugly FAILED
#
# Revision 1.40  2007/09/27 09:34:32  marc
# - comment out copy_relevant_files because of problems with kudzu
#
# Revision 1.39  2007/09/26 11:56:02  marc
# cosmetic changes
#
# Revision 1.38  2007/09/26 11:40:48  mark
# moved network config before storage config
#
# Revision 1.37  2007/09/18 10:06:36  mark
# removed unneeded code
#
# Revision 1.36  2007/09/14 13:28:54  marc
# - Fixed Bug BZ#31
#
# Revision 1.35  2007/09/07 08:04:18  mark
# added cleanup_initrd
#
# Revision 1.34  2007/08/06 15:56:14  mark
# new chroot environment
# bootimage release 1.3
#
# Revision 1.33  2007/05/23 09:15:35  mark
# added support fur RHEL4u5
#
# Revision 1.32  2007/03/09 18:01:11  mark
# added support for nash like switchRoot
#
# Revision 1.31  2007/02/09 11:06:16  marc
# added nodeid and nodename
#
# Revision 1.30  2007/01/19 13:40:20  mark
# init_cmd uses full cmdline /proc/cmdline like nash
# fixes bug #21
#
# Revision 1.29  2006/11/10 11:37:10  mark
# modified quorumack user input
# added retry:3 waittime:5 to clusterfs_mount
#
# Revision 1.28  2006/10/06 08:35:15  marc
# added quorumack functionality
#
# Revision 1.27  2006/07/19 15:12:26  marc
# mulitpath dmapper bugfix with devices
#
# Revision 1.26  2006/07/13 14:14:57  marc
# udev_start as function
#
# Revision 1.25  2006/07/03 08:32:03  marc
# added step
#
# Revision 1.24  2006/06/19 15:56:13  marc
# added devicemapper support
#
# Revision 1.23  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.22  2006/05/12 13:02:24  marc
# Major changes for Version 1.0.
# Loads of Bugfixes everywhere.
#
# Revision 1.21  2006/05/07 11:34:58  marc
# major change to version 1.0.
# Complete redesign.
#
# Revision 1.20  2006/05/03 12:46:24  marc
# added documentation
#
# Revision 1.19  2006/01/28 15:10:23  marc
# added cvs tags
#
