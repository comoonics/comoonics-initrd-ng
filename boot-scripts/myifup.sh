#!/bin/bash
#
# $Id: myifup.sh,v 1.1 2004-07-31 11:24:43 marc Exp $
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


. etc/sysconfig/comoonics

# initstuff is done in here
source /etc/boot-lib.sh

initBootProcess

ipConfig=`getBootParm ip dhcp`

echo_local_debug "*****************************"
echo_local "2. Setting up the network"

echo_local -n "2.0 Interface lo..."
exec_local /sbin/ifconfig lo 127.0.0.1 up

if [ -n "$ipConfig" ]; then
  NETDEV=$(getPosFromIPString 6 $ipConfig)
  if [ -z "$NETDEV" ]; then NETDEV=eth0; fi
  echo_local -n "2.1 Configuring network with bootparm-config ($ipConfig)"
  exec_local ip2Config $ipConfig
  echo_local_debug "2.1.1 /etc/sysconfig/network"
  exec_local_debug cat /etc/sysconfig/network
  echo_local_debug "2.1.2 /etc/sysconfig/network-scripts/ifcfg-${NETDEV}"
  exec_local_debug cat /etc/sysconfig/network-scripts/ifcfg-${NETDEV}
  echo_local -n "2.1.3 Powering up the network for interface ($NETDEV)..."
  exec_local my_ifup $NETDEV
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
    else
      echo_local "2.1 Autoprobing for network environment..."
      test `/bin/hostname` || /bin/hostname ${HOSTNAME}
      echo_local -n "2.1.1 hostname : ${HOSTNAME}"
      
      if [ ! -z ${GATEWAY} ]; then
        exec_local /sbin/route add default gw ${GATEWAY} ${DEVICE} 1>>/var/log/boot.log 2>&1
      fi
      echo_local -n "2.1.2 Ip-Address for GFS-Node"
      case $IPADDR_GFS in
        hostname)
	  name=`hostname`
	  ipaddress_from_name
	  ;;
        eth[0-9])
	  netdev=$IPADDR_GFS
	  ipaddress_from_dev
	  ;;
        [0-9]*.[0-9]*.[0-9]*.[0-9]*)
	  gfsip=$IPADDR_GFS
	  ;;
        *)
	  name=`hostname`
	  ipaddress_from_name
	  ;;
      esac
      echo_local "(OK)"
    fi
  done
fi
step
