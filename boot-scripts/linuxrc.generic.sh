#!/bin/bash
#
# $Id: linuxrc.generic.sh,v 1.21 2006-05-07 11:34:58 marc Exp $
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
#    $Id: linuxrc.generic.sh,v 1.21 2006-05-07 11:34:58 marc Exp $
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
echo_local 'Internal Version $Revision: 1.21 $ $Date: 2006-05-07 11:34:58 $'
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
debug=$(echo "$bootparms" | head -1 | tail -1)
stepmode=$(echo "$bootparms" | head -2 | tail -1)
mount_opts=$(echo "$bootparms" | head -3 | tail -1)
tmpfix=$(echo "$bootparms" | head -4 | tail -1)
return_code 0

# network parameters
echo_local -n "Scanning for network parameters..."
netparms=$(getNetParameters)
ipConfig=$(echo "$netparms" | head -1 | tail -1)
return_code 0

# clusterfs parameters
echo_local -n "Scanning for clusterfs parameters..."
cfsparams=$(getClusterFSParameters)
rootsource=$(echo "$cfsparams" | head -1 | tail -1)
root=$(echo "$cfsparams" | head -2 | tail -1)
lockmethod=$(echo "$cfsparams" | head -3 | tail -1)
sourceserver=$(echo "$cfsparams" | head -4 | tail -1)
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
cfsparams=$(clusterfs_config $cluster_conf)
nodeid=$(echo "$cfsparams" | head -1)
nodename=$(echo "$cfsparams" | head -2 | tail -1)
rootvolume=$(echo "$cfsparams" | head -3 | tail -1)
_ipConfig=$(echo "$cfsparams" | head -5 | tail -1)
[ -n "$_ipConfig" ] && ipConfig=$_ipConfig
clusterfs_auto_hosts $cluster_conf

echo_local_debug "*****************************"
echo_local_debug "nodeid: $nodeid"
echo_local_debug "nodename: $nodename"
echo_local_debug "rootvolume: $rootvolume"
echo_local_debug "ipConfig: $ipConfig"
echo_local_debug "*****************************"

scsi_start
lvm_start

nicConfig $ipConfig
dev=$(getPosFromIPString 6, $ipConfig)

echo_local -n "Powering up $dev.."
exec_local nicUp $dev >/dev/null 2>&1
return_code

cc_auto_syslogconfig $cluster_conf $nodename
start_service /sbin/syslogd no_chroot -m 0
step

clusterfs_load $lockmethod
step

setHWClock
clusterfs_services_start $lockmethod
if [ $return_c -ne 0 ]; then
   echo_local "Could not start all cluster services. Exiting"
   exit_linuxrc 1
fi
step

clusterfs_mount $rootfs $root $mount_point $mount_opts
if [ $return_c -ne 0 ]; then
   echo_local "Could not mount cluster filesystem $rootfs $root to $mountpoint. Exiting"
   exit_linuxrc 1
fi
step

clusterfs_mount_cdsl $mount_point $cdsl_local_dir $nodeid $cdsl_prefix
if [ $return_c -ne 0 ]; then
   echo_local "Could not mount cdsl $cdsl_local_dir to ${cdsl_prefix}/$nodeid. Exiting"
   exit_linuxrc 1
fi
step

copy_relevant_files $cdsl_local_dir $mount_point
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

init_cmd="/sbin/init"
newroot="${new_root}"
bootlog="/var/log/comoonics-boot.log"

if [ $critical -eq 0 ]; then
  if [ -n "$tmpfix" ]; then 
    echo_local "Setting up tmp..."
    exec_local createTemp /dev/ram1
  fi

  echo_local "Cleaning up..."
  exec_local umount ${pivot_root}/proc &&
  exec_local umount ${pivot_root}/sys
  return_code
	
  echo_local -n "Stopping syslogd..."
  exec_local stop_service "syslogd" /initrd &&
  exec_local killall syslogd
  return_code

  echo_local -n "Copying logfile to $new_root/${bootlog}..."
  cat ${bootlog} >> ${new_root}/${bootlog} 2>/dev/null || cp -f ${bootlog} ${new_root}/$(basename $bootlog)
  return_code $?
  if [ -f ${new_root}/$bootlog ]; then 
    bootlog=${new_root}/$bootlog
  else 
    bootlog=${new_root}/$(basename $bootlog)
  fi
#  exec 5>> $bootlog
  step

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
# Revision 1.21  2006-05-07 11:34:58  marc
# major change to version 1.0.
# Complete redesign.
#
# Revision 1.20  2006/05/03 12:46:24  marc
# added documentation
#
# Revision 1.19  2006/01/28 15:10:23  marc
# added cvs tags
#
