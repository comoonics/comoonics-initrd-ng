#!/bin/bash
#
# $Id: linuxrc.generic.sh,v 1.28 2006-10-06 08:35:15 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
#****h* comoonics-bootimage/linuxrc.generic.sh
#  NAME
#    linuxrc
#    $Id: linuxrc.generic.sh,v 1.28 2006-10-06 08:35:15 marc Exp $
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
#  SOURCE
#
# initstuff is done in here

source /etc/sysconfig/comoonics

source /etc/boot-lib.sh
source /etc/hardware-lib.sh
source /etc/network-lib.sh
source /etc/clusterfs-lib.sh

rootfs=$(getRootFS)
source /etc/${rootfs}-lib.sh

# including all distribution dependent files
distribution=$(getDistribution)
[ -e /etc/${distribution}/hardware-lib.sh ] && source /etc/${distribution}/hardware-lib.sh
[ -e /etc/${distribution}/network-lib.sh ] && source /etc/${distribution}/network-lib.sh
[ -e /etc/${distribution}/clusterfs-lib.sh ] && source /etc/${distribution}/clusterfs-lib.sh
[ -e /etc/${distribution}/${rootfs}-lib.sh ] && source /etc/${distribution}/${rootfs}-lib.sh

echo_local "Starting ATIX initrd"
echo_local "Comoonics-Release"
release=$(cat /etc/comoonics-release)
echo_local "$release"
echo_local 'Internal Version $Revision: 1.28 $ $Date: 2006-10-06 08:35:15 $'
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
return_code 0

if [ -n "$rootsource" ] && [ "$rootsource" = "iscsi" ]; then
    source /etc/iscsi-lib.sh
    source /etc/${distribution}/iscsi-lib.sh
fi

check_cmd_params $*

echo_local_debug "*****************************"
echo_local_debug "Debug: $debug"
echo_local_debug "Stepmode: $stepmode"
echo_local_debug "mount_opts: $mount_opts"
echo_local_debug "tmpfix: $tmpfix"
echo_local_debug "ip: $ipConfig"
echo_local_debug "rootsource: $rootsource"
echo_local_debug "root: $root"
echo_local_debug "lockmethod: $lockmethod"
echo_local_debug "sourceserver: $sourceserver"
echo_local_debug "scsifailover: $scsifailover"
echo_local_debug "quorumack: $quorumack"
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

step

# cluster_conf is set in clusterfs-lib.sh or overwritten in gfs-lib.sh
cfsparams=( $(clusterfs_config $cluster_conf $ipConfig) )
nodeid=${cfsparams[0]}
nodename=${cfsparams[1]}
rootvolume=${cfsparams[2]}
_mount_opts=${cfsparams[3]}
_scsifailover=${cfsparams[4]}
_ipConfig=${cfsparams[@]:5}
[ -n "$_ipConfig" ] && ipConfig=$_ipConfig
[ -n "$_mount_opts" ] && mount_opts=$_mount_opts
[ -n "$_scsifailover" ] && scsifailover=$_scsifailover
[ -z "$root" ] || [ "$root" = "/dev/ram0" ] && root=$rootvolume
cc_auto_hosts $cluster_conf

echo_local_debug "*****************************"
echo_local_debug "nodeid: $nodeid"
echo_local_debug "nodename: $nodename"
echo_local_debug "rootvolume: $rootvolume"
echo_local_debug "scsifailover: $scsifailover"
echo_local_debug "ipConfig: $ipConfig"
echo_local_debug "*****************************"

step

dm_start
scsi_start

if [ "$scsifailover" = "mapper" ] || [ "$scsifailover" = "devicemapper" ]; then
  dm_mp_start
fi

echo_local -n "Restarting udev "
exec_local udev_start
return_code

if [ "$scsifailover" = "mapper" ] || [ "$scsifailover" = "devicemapper" ]; then
  dm_mp_start
fi

lvm_start

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
  return_code
  netdevs="$netdevs $dev"
done

cc_auto_syslogconfig $cluster_conf $nodename
start_service /sbin/syslogd no_chroot -m 0
step

clusterfs_load $lockmethod
step

if [ -z "$quorumack" ]; then
  echo_local -n "Checking for all nodes to be available"
  exec_local cluster_checkhosts_alive
  return_code
  if [ $return_c -ne 0 ]; then
  	echo_local "Could not reach all hosts from the cluster. Waiting to be manually acknowledged by user."
  	echo_local "Type YES if you are really sure that all othernodes (the other node) is physically powered off"
  	echo_local "!!!If unsure check first. Otherwise you'll risk split brain with data inconsistency!!!!"
  	echo_local -n "Waiting for USER INPUT: "
  	read -n 3 confirm
  	if [ "$confirm" != "YES" ]; then
  		echo_local "Cluster not acknowledged falling back to shell"
  		exit_linuxrc 1
  	fi
  fi
fi

setHWClock
clusterfs_services_start $lockmethod
if [ $return_c -ne 0 ]; then
   echo_local "Could not start all cluster services. Exiting"
   exit_linuxrc 1
fi
sleep 2
step

clusterfs_mount $rootfs $root $mount_point $mount_opts
if [ $return_c -ne 0 ]; then
   echo_local "Could not mount cluster filesystem $rootfs $root to $mount_point. Exiting ($mount_opts)"
   exit_linuxrc 1
fi
step

clusterfs_mount_cdsl $mount_point $cdsl_local_dir $nodeid $cdsl_prefix
if [ $return_c -ne 0 ]; then
   echo_local "Could not mount cdsl $cdsl_local_dir to ${cdsl_prefix}/$nodeid. Exiting"
   exit_linuxrc 1
fi
step

#if [ -n "$debug" ]; then set -x; fi
copy_relevant_files $cdsl_local_dir $mount_point $netdevs
#if [ -n "$debug" ]; then set +x; fi
step

cd $mount_point
if [ ! -e initrd ]; then
    /bin/mkdir initrd
fi

clusterfs_services_restart / $mount_point
restart_error=$?
step

switchRoot $mount_point initrd
critical=$?

echo_local -n "Copying logfile to $new_root/${bootlog}..."
exec_local cp -f ${pivot_root}/${bootlog} ${new_root}/${bootlog} || cp -f ${pivot_root}/${bootlog} ${new_root}/$(basename $bootlog)
if [ -f ${new_root}/$bootlog ]; then
  bootlog=${new_root}/$bootlog
else
  bootlog=${new_root}/$(basename $bootlog)
fi
exec 3>> $bootlog
exec 4>> $bootlog
return_code_warning
step

init_cmd="/sbin/init"
newroot="${new_root}"
#bootlog="/var/log/comoonics-boot.log"

if [ $critical -eq 0 ]; then
  if [ -n "$tmpfix" ]; then
    echo_local "Setting up tmp..."
    exec_local createTemp /dev/ram1
  fi

  echo_local -n "Stopping syslogd..."
  exec_local stop_service "syslogd" /${pivot_root} &&
  return_code

  dev_start

  echo_local "Copying the devicesfiles.."
  exec_local cp -a ${pivot_root}/dev/* /dev
  return_code

  echo_local "Cleaning up..."
  exec_local umount ${pivot_root}/dev &&
  exec_local umount ${pivot_root}/proc &&
  exec_local umount ${pivot_root}/sys
  return_code

  echo_local -n "Removing files in initrd"
  if [ $restart_error -eq 0 ]; then
    exec_local rm -rf ${pivot_root}/*
    return_code
  else
    passed
    # echo_local "(SKIPPED, failed restart clustersvc)"
  fi
  step
  newroot="/"

  echo_local "Starting init-process ($init_cmd)..."
  exit_linuxrc 0 "$init_cmd" "$newroot"
else
  exit_linuxrc 1
fi

#********** main

###############
# $Log: linuxrc.generic.sh,v $
# Revision 1.28  2006-10-06 08:35:15  marc
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
