#!/bin/bash
#
# $Id: linuxrc.generic.sh,v 1.10 2004-09-13 09:38:15 marc Exp $
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
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    bootpart=...          Which linuxrc.{bootpart} file should be loaded into 
#                  that script.
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output
#
# Marc Grimme: existence of /etc/gfs-lib.sh with all gfs-functions. 
#         Should be the framework for all other functionalities as well.

. etc/sysconfig/comoonics

# initstuff is done in here
source /etc/boot-lib.sh

echo_local "Starting ATIX initrd"
echo_local "Comoonics-Release"
release=$(cat /etc/comoonics-release)
echo_local $release
echo_local 'Internal Version $Revision: 1.10 $ $Date: 2004-09-13 09:38:15 $'

initBootProcess


# network parameters
getNetParameters

# gfs parameters
# getGFSParameters

# boot parameters
getBootParameters

check_cmd_params $*

echo_local_debug "Debug: $debug"
echo_local_debug "Stepmode: $stepmode"
echo_local_debug "mount_opts: $mount_opts"
echo_local_debug "bootpart: $bootpart"
echo_local_debug "ip: $ipConfig"
echo_local_debug "tmpfix: $tmpfix"
echo_local_debug "*****************************"
x=`cat /proc/version`; 
KERNEL_VERSION=`expr "$x" : 'Linux version \([^ ]*\)'`
echo_local "0.2 Kernel-verion: ${KERNEL_VERSION}"
echo_local_debug "*****************************"
step 

detectHardware

echo_local_debug "*****************************"
echo_local "2. Setting up the network"

echo_local -n "2.0 Interface lo..."
exec_local /sbin/ifconfig lo 127.0.0.1 up

if [ -n "$ipConfig" ]; then
  if [ "$IFCONFIG" = "boot" ]; then
      echo_local "2.1 Network already configured for device ${NETDEV}."
  elif [ "$ipConfig" = "skip" ] || [ "$ipConfig" = "cca" ]; then
      echo_local "2.1 Explicitly skipping network configuration. Handled later (hopefully)."
  else
      NETDEV=$(getPosFromIPString 6 $ipConfig)
      if [ -z "$NETDEV" ]; then NETDEV=eth0; fi
      echo_local -n "2.1 Configuring network with bootparm-config ($ipConfig)"
      exec_local ip2Config $ipConfig
      echo_local -n "2.1.3 Powering up the network for interface ($NETDEV)..."
      exec_local my_ifup $NETDEV $ipConfig
  fi
else
  for dev in $NETCONFIG; do
    eval IFCONFIG=\$IFCONFIG${dev}
    eval NETDEV=\$NETDEV${dev}
    echo_local "2.1 Starting Network on device ${NETDEV}/${IFCONFIG}."
    if [ "$IFCONFIG" = "default" ]; then
      echo_local "2.1.$NETDEV Powering up ${NETDEV}..."
      exec_local /sbin/ifup $NETDEV
    elif [ "$IFCONFIG" = "boot" ]; then
      echo_local "2.1 Network already configured for device ${NETDEV}."
    elif [ "$IFCONFIG" = "skip" ]; then
      echo_local "2.1 Explicitly skipping network configuration. Handled later (hopefully)."
    else
      echo_local "2.1 Autoprobing for network environment..."
      test `/bin/hostname` || /bin/hostname ${HOSTNAME}
      echo_local -n "2.1.1 hostname : ${HOSTNAME}"
      
      if [ ! -z ${GATEWAY} ]; then
        exec_local /sbin/route add default gw ${GATEWAY} ${DEVICE} 1>>/var/log/boot.log 2>&1
      fi
#      echo_local -n "2.1.2 Ip-Address for GFS-Node"
#      case $IPADDR_GFS in
#        hostname)
#	  name=`hostname`
#	  ipaddress_from_name
#	  ;;
#        eth[0-9])
#	  netdev=$IPADDR_GFS
#	  ipaddress_from_dev
#	  ;;
#        [0-9]*.[0-9]*.[0-9]*.[0-9]*)
#	  gfsip=$IPADDR_GFS
#	  ;;
#        *)
#	  name=`hostname`
#	  ipaddress_from_name
#	  ;;
#      esac
#      echo_local "(OK)"
    fi
  done
fi
step
echo_local_debug "2.2 Network Configuration: "
echo_local_debug "      1. Interfaces:"
exec_local_debug /sbin/ifconfig
echo_local_debug "      2. Routing:"
exec_local_debug /sbin/route -n
echo_local_debug "      3. Hostname:"
exec_local_debug /bin/hostname
echo_local_debug "*****************************"
step
if [ ! -e /mnt/newroot ]; then
	mkdir -p /mnt/newroot
fi


source /linuxrc.part.${bootpart}.sh

