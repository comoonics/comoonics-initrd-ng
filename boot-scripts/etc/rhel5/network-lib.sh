#
# $Id: network-lib.sh,v 1.2 2008-01-24 13:35:15 marc Exp $
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
#****h* boot-scripts/etc/rhel5/network-lib.sh
#  NAME
#    network-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for network support functions for RHEL5.
#*******


#****f* boot-lib.sh/rhel5_ip2Config
#  NAME
#    rhel4_ip2Config
#  SYNOPSIS
#    function rhel4_ip2Config(ipDevice, ipAddr, ipGate, ipNetmask, ipHostname) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function rhel5_ip2Config() {
  local ipDevice=$1
  local ipAddr=$2

  echo "$ipAddr" | grep "[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*" </dev/null 2>&1
  if [ -n "$ipAddr" ]; then
    local ipNetmask=$3
    local ipHostname=$4
    local ipGate=$5
    local MAC=$6
  else
    local master=$3
    local slave=$4
  	local bridge=$5
  	local MAC=$6
  fi

  # reformating MAC from - to :
  MAC=${MAC//-/:}

  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  if [ -e ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ]; then
    mv ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ${__prefix}/etc/sysconfig/network-scripts/ifcfg-${ipDevice}.com_back
  fi

  (echo "DEVICE=$ipDevice" &&
   echo "ONBOOT=no" &&
   echo "TYPE=Ethernet") > ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice

  [ -n "$MAC" ] && echo "HWADDR=$MAC" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice

  # test for vlan config
  if [[ "$ipDevice" =~ "[a-z]+[0-9]+\.[0-9]+" ]]; then
	echo "VLAN=yes" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
  fi

  if [ -n "$ipAddr" ]; then
    if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then
      bootproto="dhcp"
    else
      bootproto="static"
    fi

    echo "BOOTPROTO=$bootproto" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
    if [ "$bootproto" != "dhcp" ]; then
      (echo "IPADDR=$ipAddr" &&
       if [ -n "$ipNetmask" ]; then echo "NETMASK=$ipNetmask"; fi) >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
      if [ -n "$ipGate" ]; then
	    echo "GATEWAY=$ipGate" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
      fi
    fi
  else
     [ -n "$master" ] && echo "MASTER=${master}" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     [ -n "$slave" ] &&  echo "SLAVE=${slave}"   >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     [ -n "$bridge" ] && echo "BRIDGE=${bridge}" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
  fi
  return 0
}
#************ rhel5_ip2Config

#################
# $Log: network-lib.sh,v $
# Revision 1.2  2008-01-24 13:35:15  marc
# - RFE#145 macaddress will be generated in configuration files
#
# Revision 1.1  2007/09/07 07:57:55  mark
# initial check in
#
# Revision 1.3  2007/01/19 10:04:16  mark
# added vlan support
#
# Revision 1.2  2006/05/12 13:03:24  marc
# First stable version 1.0.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
