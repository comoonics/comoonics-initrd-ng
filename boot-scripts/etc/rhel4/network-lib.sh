#
# $Id: network-lib.sh,v 1.3 2007-01-19 10:04:16 mark Exp $
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
#****h* boot-scripts/etc/rhel8/network-lib.sh
#  NAME
#    network-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for network support functions for RHEL4.
#*******


#****f* boot-lib.sh/rhel4_ip2Config
#  NAME
#    rhel4_ip2Config
#  SYNOPSIS
#    function rhel4_ip2Config(ipDevice, ipAddr, ipGate, ipNetmask, ipHostname) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function rhel4_ip2Config() {
  local ipDevice=$1
  local ipAddr=$2

  #Bonding
  echo "$ipAddr" | grep "[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*" </dev/null 2>&1
  if [ -n "$ipAddr" ]; then
    local ipNetmask=$3
    local ipHostname=$3
    local ipGate=$5
  else
    local master=$3
    local slave=$4
  fi

  # just for testing
  #local $pref="/tmp"

  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  # first save
#  if [ -e ${__prefix}/etc/sysconfig/network ]; then
#    mv ${__prefix}/etc/sysconfig/network ${__prefix}/etc/sysconfig/network.com_back
#  fi
  if [ -e ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ]; then
    mv ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ${__prefix}/etc/sysconfig/network-scripts/ifcfg-${ipDevice}.com_back
  fi
  if [ -n "$ipAddr" ]; then
    if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then
      bootproto="dhcp"
    else
      bootproto="none"
    fi

    (echo "DEVICE=$ipDevice" &&
     echo "BOOTPROTO=$bootproto" &&
     echo "ONBOOT=no" &&
     echo "TYPE=Ethernet") > ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
    if [ "$bootproto" != "dhcp" ]; then
      (echo "IPADDR=$ipAddr" &&
      if [ -n "$ipNetmask" ]; then echo "NETMASK=$ipNetmask"; fi) >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
      if [ -n "$ipGate" ]; then
	    echo "GATEWAY=$ipGate" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
      fi
      # test for vlan config
	  if [[ "$ipDevice" =~ "[a-z]+[0-9]+\.[0-9]+" ]]; then
		echo "VLAN=yes" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
	  fi
    fi
  else
    (echo "DEVICE=$ipDevice" &&
     echo "BOOTPROTO=none" &&
     echo "ONBOOT=no" &&
     echo "MASTER=${master}" &&
     echo "SLAVE=${slave}" &&
     echo "TYPE=Ethernet") > ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
  fi
#   (echo "NETWORKING=yes" &&
#    echo "HOSTNAME=$ipHostname") > ${__prefix}/etc/sysconfig/network
#   if [ $(/bin/hostname) = "(none)" ] || [ $(/bin/hostname) = "localhost.localdomain" ] || [ $(/bin/hostname) = "localhost" ]; then
#       /bin/hostname $ipHostname;
#   fi
#   echo_local_debug "   /etc/sysconfig/network"
#   exec_local_debug cat /etc/sysconfig/network
#   echo_local_debug "   /etc/sysconfig/network-scripts/ifcfg-${ipDevice}"
#   exec_local_debug cat /etc/sysconfig/network-scripts/ifcfg-${ipDevice}
   return 0
}
#************ rhel4_ip2Config

#################
# $Log: network-lib.sh,v $
# Revision 1.3  2007-01-19 10:04:16  mark
# added vlan support
#
# Revision 1.2  2006/05/12 13:03:24  marc
# First stable version 1.0.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
