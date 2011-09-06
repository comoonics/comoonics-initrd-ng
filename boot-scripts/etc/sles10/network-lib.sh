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
#****h* boot-scripts/etc/sles10/network-lib.sh
#  NAME
#    network-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for network support functions for SLES8.
#*******

#****f* sles10/network-lib.sh/sles10_ip2Config
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
  shift 9
  local properties=$*
  local property=""
  
  if [ "$onboot" = "yes" ]; then
  	onboot="nfsroot"
  fi

  # reformating MAC from - to :
  MAC=${MAC//-/:}

  if [ -z "$type" ]; then type="Ethernet"; fi
  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  [ -z "$networkpath" ] && local networkpath=${__prefix}/$(sles10_get_networkpath)
#  if [ -e ${networkpath}/ifcfg-$ipDevice ]; then
#    mv -f ${networkpath}/ifcfg-$ipDevice ${networkpath}/ifcfg-$ipDevice.com_back
#  fi
  local vlan=
  if [[ "$ipDevice" =~ "[a-z]+[0-9]+\.[0-9]+" ]]; then
    vlan=$(echo $ipDevice | sed -e 's/^.*\.\([[:digit:]][[:digit:]]\)/\1/')
    etherdevice=$(echo $ipDevice | sed -e 's/^\(.*\).[[:digit:]][[:digit:]]/\1/')
    repository_store_value "${ipDevice}_alias" "vlan$vlan"
    ipDevice="vlan$vlan"
  fi

  (echo 'NM_CONTROLLED=no' &&
   echo 'DEVICE="'$ipDevice'"' &&
   echo 'STARTMODE="'$onboot'"' &&
   echo 'TYPE="'$type'"') >> ${networkpath}/ifcfg-$ipDevice

  #[ -n "$MAC" ] && [ "$MAC" != "00:00:00:00:00:00" ] && echo "HWADDR=$MAC" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice

  # test for vlan config
  if [ -n "$vlan" ]; then   
	echo 'VLAN="yes"' >> ${networkpath}/ifcfg-$ipDevice
	echo 'ETHERDEVICE="'$etherdevice'"' >> ${networkpath}/ifcfg-$ipDevice
  fi

  if [ -n "$ipAddr" ]; then
    if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then
      bootproto="dhcp"
    else
      bootproto="static"
    fi

    echo 'BOOTPROTO="'$bootproto'"' >> ${networkpath}/ifcfg-$ipDevice
    if [ "$bootproto" != "dhcp" ]; then
      (echo 'IPADDR="'$ipAddr'"' &&
      if [ -n "$ipNetmask" ]; then echo 'NETMASK="'$ipNetmask'"'; fi) >> ${networkpath}/ifcfg-$ipDevice
      if [ -n "$ipGate" ]; then
	    echo "default $ipGate 0.0.0.0 $ipDevice" > ${networkpath}/ifroute-$ipDevice
      fi
    fi
  else
     local slaveno=$(echo $ipDevice | sed -e 's/.*\([[:digit:]][[:digit:]]*\)/\1/')
     [ -n "$master" ] && echo 'BONDING_SLAVE'${slaveno}'="'$ipDevice'"' >> ${networkpath}/ifcfg-$master
     [ -n "$slave" ] &&  echo 'BONDING_MASTER="'${slave}'"'   >> ${networkpath}/ifcfg-$master
     [ -n "$bridge" ] && echo 'BRIDGE="'${bridge}'"' >> ${networkpath}/ifcfg-$ipDevice
  fi

  local propertynames=$(echo "$properties" | sed -e 's/=\"[^"]*\"//g' -e "s/=\'[^']*\'//g" -e 's/=\S*//g')
  eval "$properties"
  
  for property in $propertynames; do
  	echo "$property=\""$(eval echo \$$property)"\"" >> ${networkpath}/ifcfg-$ipDevice
  done
  return 0
}
#************ sles10_ip2Config 

#****f* sles10/network-lib.sh/nicUp
#  NAME
#    nicUp
#  SYNOPSIS
#    function nicUp()
#  DOCUMENTATION
#    Powers up the network interface
#  SOURCE
#
function nicUp() {
   local alias=$(repository_get_value "$1_alias" $1)
   /sbin/ifup $alias
}
#************ nicUp

#****f* sles10/network-lib/sles10_get_networkpath
#  NAME
#    sles10_get_networkpath
#  SYNOPSIS
#    function sles10_get_networkpath()
#  MODIFICATION HISTORY
#  IDEAS
#    returns distribution dependent the path to the network configuration files
#  SOURCE
#
sles10_get_networkpath() {
	echo "/etc/sysconfig/network"
}
#************ sles10_get_networkpath
