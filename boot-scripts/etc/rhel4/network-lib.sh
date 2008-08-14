#
# $Id: network-lib.sh,v 1.8 2008-08-14 13:33:04 marc Exp $
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

#
#****h* boot-scripts/etc/rhel4/network-lib.sh
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
  local ipMAC=$6
  local type=$7
  local bridge=$8

  # reformating MAC from - to :
  ipMAC=${ipMAC//-/:}
 
  if [ -z "$type" ]; then type="Ethernet"; fi
  # just for testing
  #local $pref="/tmp"

  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  # first save
#  if [ -e ${__prefix}/etc/sysconfig/network ]; then
#    mv ${__prefix}/etc/sysconfig/network ${__prefix}/etc/sysconfig/network.com_back
#  fi
  if [ -e ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ]; then
    mv -f ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ${__prefix}/etc/sysconfig/network-scripts/ifcfg-${ipDevice}.com_back
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
     echo "TYPE=$type") > ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
    if [ -n "$ipMAC" ] && [ "$ipMAC" != "00:00:00:00:00:00" ]; then
    	echo "HWADDR=$ipMAC" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
    fi
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
# Revision 1.8  2008-08-14 13:33:04  marc
# - rewrote briding
# - fix mac bug
#
# Revision 1.7  2008/06/10 09:59:44  marc
# - fixed bug with macaddress
#
# Revision 1.6  2008/05/17 08:31:34  marc
# fixed BUG with wrong mac-address creation. Already fixed in rhel5 but not here
#
# Revision 1.5  2008/01/24 13:33:58  marc
# - RFE#145 macaddress will be generated in configuration files
#
# Revision 1.4  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
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
