#
# $Id: network-lib.sh,v 1.5 2009-09-28 12:47:14 marc Exp $
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
#****h* boot-scripts/etc/sles8/network-lib.sh
#  NAME
#    network-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for network support functions for SLES8.
#*******

#****f* boot-lib.sh/sles10_ip2Config
#  NAME
#    sles10_ip2Config
#  SYNOPSIS
#    function sles10_ip2Config(ipDevice, ipAddr, ipGate, ipNetmask, ipHostname) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function sles10_ip2Config() {
  local ipDevice=$1
  local ipAddr=$2

  echo "$ipAddr" | grep "[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*" </dev/null 2>&1
  if [ -n "$ipAddr" ]; then
    local ipNetmask=$3
    local ipHostname=$4
    local ipGate=$5
  else
    local master=$3
    local slave=$4
  fi
  local MAC=$6
  local type=$7
  local bridge=$8
  local onboot=$9
  
  if [ "$onboot" = "yes" ]; then
  	onboot="nfsroot"
  fi

  # reformating MAC from - to :
  MAC=${MAC//-/:}

  if [ -z "$type" ]; then type="Ethernet"; fi
  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  if [ -e ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice ]; then
    mv -f ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice ${__prefix}/etc/sysconfig/network/ifcfg-${ipDevice}.com_back
  fi

  (echo 'NM_CONTROLLED=no' &&
   echo 'DEVICE="'$ipDevice'"' &&
   echo 'STARTMODE="'$onboot'"' &&
   echo 'TYPE="'$type'"') > ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice

  #[ -n "$MAC" ] && [ "$MAC" != "00:00:00:00:00:00" ] && echo "HWADDR=$MAC" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice

  # test for vlan config
  if [[ "$ipDevice" =~ "[a-z]+[0-9]+\.[0-9]+" ]]; then
	echo 'VLAN="yes"' >> ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice
  fi

  if [ -n "$ipAddr" ]; then
    if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then
      bootproto="dhcp"
    else
      bootproto="static"
    fi

    echo 'BOOTPROTO="'$bootproto'"' >> ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice
    if [ "$bootproto" != "dhcp" ]; then
      (echo 'IPADDR="'$ipAddr'"' &&
      if [ -n "$ipNetmask" ]; then echo 'NETMASK="'$ipNetmask'"'; fi) >> ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice
      if [ -n "$ipGate" ]; then
	    echo "default $ipGate 0.0.0.0 $ipDevice" > ${__prefix}/etc/sysconfig/network/ifroute-$ipDevice
      fi
    fi
  else
     [ -n "$master" ] && echo 'MASTER="'${master}'"' >> ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice
     [ -n "$slave" ] &&  echo 'SLAVE="'${slave}'"'   >> ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice
     [ -n "$bridge" ] && echo 'BRIDGE="'${bridge}'"' >> ${__prefix}/etc/sysconfig/network/ifcfg-$ipDevice
  fi
  return 0
}
#************ sles10_ip2Config 

#****f* boot-lib.sh/nicUp
#  NAME
#    nicUp
#  SYNOPSIS
#    function nicUp()
#  DOCUMENTATION
#    Powers up the network interface
#  SOURCE
#
function nicUp() {
   /sbin/ifup $1
}
#************ ifup

#################
# $Log: network-lib.sh,v $
# Revision 1.5  2009-09-28 12:47:14  marc
# added function nicUp to overwrite defaults nicUp
#
# Revision 1.4  2009/04/22 11:36:45  marc
# - upstream for sles10
#
# Revision 1.3  2008/10/14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#
# Revision 1.2  2008/09/23 18:24:38  marc
# fixed bug#272 where static ips would not be specified in network configuration.
#
# Revision 1.1  2008/08/14 13:30:52  marc
# initial revision
#
# Revision 1.2  2007/12/07 16:40:00  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
