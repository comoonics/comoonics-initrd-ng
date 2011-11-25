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
  local ipconfig=$1
  local dev=$(getPosFromIPString 6, $ipconfig)
  local hwids=$2
  
  [ -z "$hwids" ] && hwids=$(repository_get_value hardwareids)

  return_c=0
#  if [ "$dev" != "lo" ] && [ "$dev" != "lo0" ]; then
#    modprobe $dev && sleep 2 && ifconfig $dev up
#  fi

  # let's have a look if the mac of this nic matches to the name of the nic specified. If not change it.
  for _hwid in $hwids; do
  	  local devmay=$(echo "$_hwid" | cut -f1 -d:)
  	  local macmay=$(echo "$_hwid" | cut -f2- -d:)
  	  local macwish=$(getPosFromIPString 7, $ipconfig)
  	  local driver=$(getPosFromIPString 11, $ipconfig)
  	  local macis=$(ifconfig $dev | grep -v -i "Link encap: Local" | grep -v -i "Link encap:UNSPEC" | grep -i hwaddr | awk '{print $5;};')
      macwish=${macwish//-/:}  	  
  	  if [ -z "$driver" ] && [ -n "$devmay" ] && [ -n "$macmay" ] && [ -n "$macwish" ] && [ "$macmay" = "$macwish" ] && [ "$dev" != "$devmay" ]; then
  	  	if [ -z "$macis" ] || [ "$macis" != "$macwish" ]; then
  	  	  echo_local -N -n "moving nicname from $dev => $devmay." >&2
  	      ipconfig=$(setPosAtIPString 6 $devmay $ipconfig)
  	  	fi
  	  fi  
  done

  if [ -n "$ipconfig" ] && [ "$ipconfig" != "skip" ]; then
    sleep 2
    xen_dom0_detect
    if [ $? -eq 0 ]; then
      xen_ip2Config $ipconfig
    else
      exec_local ip2Config ${ipconfig} >&2
    fi
    echo "$ipconfig"
#    exec_local ip2Config $(getPosFromIPString 1, $ipconfig):$(getPosFromIPString 2, $ipconfig):$(getPosFromIPString 3, $ipconfig):$(getPosFromIPString 4, $ipconfig):$(hostname):$dev
  fi
}
#******** nicConfig

#****f* boot-lib.sh/nicAutoUp
#  NAME
#    nicAutoUp
#  SYNOPSIS
#    function nicAutoUp ipconfig
#  DOCUMENTATION
#    Returns 0 if nic should be taken up configurated
#  SOURCE
#
function nicAutoUp() {
   local _err=0
   local ipconfig=$1
   local onboot=$(getPosFromIPString 10, $ipconfig)
   if [ "$onboot" = "yes" ]; then
   	return 0
   else
    return 1
   fi
}
#************ nicAutoUp

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
   local count=0
   local maxcount=${timeout:-30}
   local timeout=${timeout:-2}
   /sbin/ifup $*
   errorcode=$?
   while ! ip link show dev "$1" | grep "UP,LOWER_UP" &>/dev/null && [ "$count" -le $maxcount ]; do sleep $timeout; count=$(( $count + 1 )); done
   ip link show dev "$1" | grep "UP,LOWER_UP" &>/dev/null
   return $?
}
#************ ifup

#****f* boot-lib.sh/ip2Config
#  NAME
#    ip2Config
#  SYNOPSIS
#    function ip2Config(ipConfig)
#    function ip2Config(ipAddr, ipGate, ipNetmask, ipHostname, ipDevice, master, slave, bridge, type, onboot, (name=value)*)
#  MODIFICATION HISTORY
#  IDEAS
#    ipConfig=addr':'      ':'gateway':'netmask':'hostname':'device':'mac':'type':'bridge':'onboot':'(name'='value':')* |
#                 ':'master':'slave  ':'       ':'        ':'device':'mac':'type':'bridge':'onboot':'(name'='value':')*
#  SOURCE
#
function ip2Config() {
  [ -z "$distribution" ] && local distribution=$(repository_get_value distribution)

  if [ $# -eq 1 ]; then
    local ipAddr=$(getPosFromIPString 1, "$1")

    #Bonding
    if [ -n "$ipAddr" ]; then
      local ipGate=$(getPosFromIPString 3, "$1")
      local ipNetmask=$(getPosFromIPString 4, "$1")
      local ipHostname=$(getPosFromIPString 5, "$1")
    else
      local master=$(getPosFromIPString 2, "$1")
      local slave=$(getPosFromIPString 3, "$1")
    fi
    local ipDevice=$(getPosFromIPString 6, "$1")
    local ipMAC=$(getPosFromIPString 7, "$1")
    local type=$(getPosFromIPString 8, "$1")
    local bridge=$(getPosFromIPString 9, "$1")
    local onboot=$(getPosFromIPString 10, "$1")
    local properties=""
    local i=12
    local property=$(getPosFromIPString $i, "$1") 
    while [ $(echo "$1" | awk -F ":" 'END { print NF; }') -gt $i ]; do
      properties="$properties $property"
      i=$(($i + 1))
      property=$(getPosFromIPString $i, "$1")
    done
    [ -n "$property" ] && properties="$properties $property"
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
    local type=$10
    local onboot=$11
    [ -z "$onboot" ] && onboot="yes"
    shift 11
    local properties=$*
  fi

  # Bonding
  if [ -n "$ipAddr" ]; then
  	echo_local_debug -N -n ".. ifcfg for ${distribution} ($ipAddr, $ipGate, $ipNetmask, $ipHostname, $ipDevice, $ipMAC)..."
    ${distribution}_ip2Config "$ipDevice" "$ipAddr" "$ipNetmask" "$ipHostname" "$ipGate" "$ipMAC" "$type" "$bridge" "$onboot" $properties
  else
	echo_local_debug -N -n ".. ifcfg for ${distribution} ($master, $slave, $bridge, $ipDevice, $ipMAC)..."
    ${distribution}_ip2Config "$ipDevice" "" "$master" "$slave" "" "$ipMAC" "$type" "$bridge" "$onboot" $properties
  fi
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
   local drivers=$*
   if [ -z "$drivers" ] && [ -n "$modules_conf" ] && [ -e "$modules_conf" ]; then
     drivers=$(cat $modules_conf | grep "alias eth[0-9]" | awk '{print $2;}')
   fi
   
   echo_local -n "Loading modules for all found network cards"
   for module in $drivers; do
      exec_local modprobe $module
   done
   return_code
}
#******** auto_netconfig

#****f* boot-lib.sh/found_nics
#  NAME
#    found_nics
#  SYNOPSIS
#    function found_nics
#  DESCRIPTION
#    Just returns how many NICs were found on this system
#
function found_nics {
  local nics
  for nic in $(ls /sys/class/net); do
  	if [ -f /sys/class/net/${nic}/address ] && [ -f /sys/class/net/${nic}/type ] && [ "$(cat /sys/class/net/${nic}/type)" -lt 256 ]; then
      echo "$nic"
  	  nics=$(($nics + 1))
  	fi
  done
  test -n "$nics" && test $nics -gt 0
  return $?
}
#******** found_nics
	
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
  getPosFromList "$1" "$2" ":"
}
#************ getPosFromIPString

#****f* boot-lib.sh/setPosAtIPString
#  NAME
#    setPosAtIPString
#  SYNOPSIS
#    function setPosFromIPString(pos, value, ipstring) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function setPosAtIPString() {
  local pos=$1
  local value=$2
  local str=$3
  setPosAtList "$1" "$2" "$3" ":"
}
#************ getPosFromIPString
