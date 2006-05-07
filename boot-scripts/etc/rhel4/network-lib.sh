#
# $Id: network-lib.sh,v 1.1 2006-05-07 11:33:40 marc Exp $
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
  local ipNetmask=$3
  local ipHostname=$3
  local ipGate=$5

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
  if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then 
    bootproto="dhcp"
  else 
    bootproto="static"
  fi
  (echo "DEVICE=$ipDevice" && 
   echo "BOOTPROTO=$bootproto" && 
   echo "ONBOOT=no") > ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
  if [ "$bootproto" != "dhcp" ]; then
     (echo "IPADDR=$ipAddr" && 
	 if [ -n "$ipNetmask" ]; then echo "NETMASK=$ipNetmask"; fi) >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     if [ -n "$ipGate" ]; then 
	 echo "GATEWAY=$ipGate" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     fi
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
# Revision 1.1  2006-05-07 11:33:40  marc
# initial revision
#
