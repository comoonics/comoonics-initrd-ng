#
# $Id: network-lib.sh,v 1.7 2008-01-24 13:33:17 marc Exp $
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
#****h* boot-scripts/etc/network-lib.sh
#  NAME
#    network-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for general network support functions.
#*******

#****b* boot-scripts/etc/network-lib.sh/ip
#  NAME
#    ip
#  DESCRIPTION
#    The ip bootparameter holds the configuration for the ip stack of
#    the initrd. Valid modes are:
#      * cluster: the configuration is get from the cluster (default).
#      * ipstring: as defined in the standard boot paramters
#      * dhcp: ip as configured via dhcp
#********* ip

#****f* boot-lib.sh/getNetParameters
#  NAME
#    getNetParameters
#  SYNOPSIS
#    function getNetParameters()
#  DESCRIPTION
#    Gets all network relevant bootparamters. "ip" is so far the
#    only supported parameter.
#  SOURCE
#
function getNetParameters() {
   getBootParm ip "cluster"
}
#************ getNetParameters

#****f* boot-lib.sh/nicConfig
#  NAME
#    nicConfig
#  SYNOPSIS
#    function nicConfig(dev, ipConfig)
#  DESCRIPTION
#    Creates a network configuration file for the given network device
#    and the ip configuration.
#  SOURCE
function nicConfig {
#  local dev=$1
  local ipconfig=$1

  dev=$(getPosFromIPString 6, $ipconfig)

  return_c=0
  if [ "$dev" != "lo" ] && [ "$dev" != "lo0" ]; then
    echo_local -n "Loading module for $dev..."
    exec_local modprobe $dev && sleep 2 && ifconfig $dev up
    return_code
  fi

  if [ -n "$ipconfig" ] && [ "$ipconfig" != "skip" ]; then
    sleep 2
    echo_local "Creating network configuration for $dev"
    xen_dom0_detect
    if [ $? -eq 0 ]; then
      xen_ip2Config $ipconfig
    else
      exec_local ip2Config ${ipconfig}
    fi
#    exec_local ip2Config $(getPosFromIPString 1, $ipconfig):$(getPosFromIPString 2, $ipconfig):$(getPosFromIPString 3, $ipconfig):$(getPosFromIPString 4, $ipconfig):$(hostname):$dev
  fi
}
#******** nicConfig

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
   local _err=0
   local dev=$1
   /sbin/ifup $dev
   _err=$?
   if [ "${dev:0:2}" != "lo" ]; then
     xen_dom0_detect
     if [ $? -eq 0 ]; then
       xen_nic_post $dev
     fi
   fi
   return $_err

}
#************ ifup

#****f* boot-lib.sh/ip2Config
#  NAME
#    ip2Config
#  SYNOPSIS
#    function ip2Config(ipConfig)
#    function ip2Config(ipAddr, ipGate, ipNetmask, ipHostname, ipDevice, master, slave, bridge)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function ip2Config() {
  if [ $# -eq 1 ]; then
    local ipAddr=$(getPosFromIPString 1, $1)

    #Bonding
    echo "$ipAddr" | grep "[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*" </dev/null 2>&1
    if [ -n "$ipAddr" ]; then
      local ipGate=$(getPosFromIPString 3, $1)
      local ipNetmask=$(getPosFromIPString 4, $1)
      local ipHostname=$(getPosFromIPString 5, $1)
    else
      local master=$(getPosFromIPString 2, $1)
      local slave=$(getPosFromIPString 3, $1)
      local bridge=$(getPosFromIPString 8, $1)
    fi
    local ipDevice=$(getPosFromIPString 6, $1)
    local ipMAC=$(getPosFromIPString 7, $1)
  else
    local ipAddr=$1
    local ipGate=$2
    local ipNetmask=$3
    local ipHostname=$4
    local ipDevice=$5
    local ipMAC=$6
    local master=$7
    local slave=$8
    local bridge=$9
  fi

  # Bonding
  if [ -n "$ipAddr" ]; then
  	echo_local -n "Generating ifcfg for ${distribution} ($ipAddr, $ipGate, $ipNetmask, $ipHostname, $ipDevice, $ipMAC)..."
    ${distribution}_ip2Config "$ipDevice" "$ipAddr" "$ipNetmask" "$ipHostname" "$ipGate" "$ipMAC"
  else
	echo_local -n "Generating ifcfg for ${distribution} ($master, $slave, $bridge, $ipDevice, $ipMAC)..."
    ${distribution}_ip2Config "$ipDevice" "" "$master" "$slave" "$bridge" "$ipMAC"
  fi
  return_code $?
}
#************ ip2Config

#****f* boot-lib.sh/auto_netconfig
#  NAME
#    auto_netconfig
#  SYNOPSIS
#    function auto_netconfig
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function auto_netconfig {
   echo_local "Loading modules for all found network cards"
   modules=$(cat $modules_conf | grep "alias eth[0-9]" | awk '{print $2;}')
   for module in $modules; do
      exec_local modprobe $module
   done
   return_code
}
#******** auto_netconfig
#****f* boot-lib.sh/getPosFromIPString
#  NAME
#    getPosFromIPString
#  SYNOPSIS
#    function getPosFromIPString() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getPosFromIPString() {
  pos=$1
  str=$2
  echo $str | awk -v pos=$pos 'BEGIN { FS=":"; }{ print $pos; }'
}
#************ getPosFromIPString

#############
# $Log: network-lib.sh,v $
# Revision 1.7  2008-01-24 13:33:17  marc
# - RFE#145 macaddress will be generated in configuration files
#
# Revision 1.6  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.5  2007/10/10 15:08:56  mark
# fix for BZ138
#
# Revision 1.4  2007/10/05 10:07:31  marc
# - added xen-support
#
# Revision 1.3  2007/09/14 13:28:31  marc
# no changes
#
# Revision 1.2  2006/05/12 13:06:41  marc
# First stable Version 1.0 for initrd.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
