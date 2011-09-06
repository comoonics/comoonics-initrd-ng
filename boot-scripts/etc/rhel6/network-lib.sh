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
#****h* boot-scripts/etc/fedora9/network-lib.sh
#  NAME
#    network-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for network support functions for RHEL5.
#*******

#****f* boot-lib.sh/rhel6_ip2Config
#  NAME
#    rhel6_ip2Config
#  SYNOPSIS
#    function rhel6_ip2Config(ipDevice, ipAddr, ipGate, ipNetmask, ipHostname) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function rhel6_ip2Config() {
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

  # reformating MAC from - to :
  MAC=${MAC//-/:}

  if [ -z "$type" ]; then type="Ethernet"; fi
  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  [ -z "$networkpath" ] && local networkpath=${__prefix}/$(rhel6_get_networkpath)

  if [ -e ${networkpath}/ifcfg-$ipDevice ]; then
    mv -f ${networkpath}/ifcfg-$ipDevice ${networkpath}/ifcfg-$ipDevice.com_back
  fi

  (echo "DEVICE=$ipDevice" &&
   echo "ONBOOT=$onboot" &&
   echo "TYPE=$type") > ${networkpath}/ifcfg-$ipDevice

  [ -n "$MAC" ] && [ "$MAC" != "00:00:00:00:00:00" ] && echo "HWADDR=$MAC" >> ${networkpath}/ifcfg-$ipDevice

  # test for vlan config
  if [[ "$ipDevice" =~ "[a-z]+[0-9]+\.[0-9]+" ]]; then
	echo "VLAN=yes" >> ${networkpath}/ifcfg-$ipDevice
  fi

  if [ -n "$ipAddr" ]; then
    if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then
      bootproto="dhcp"
    else
      bootproto="static"
    fi

    echo "BOOTPROTO=$bootproto" >> ${networkpath}/ifcfg-$ipDevice
    if [ "$bootproto" != "dhcp" ]; then
      (echo "IPADDR=$ipAddr" &&
       if [ -n "$ipNetmask" ]; then echo "NETMASK=$ipNetmask"; fi) >> ${networkpath}/ifcfg-$ipDevice
      if [ -n "$ipGate" ]; then
	    echo "GATEWAY=$ipGate" >> ${networkpath}/ifcfg-$ipDevice
      fi
    fi
  else
     [ -n "$master" ] && echo "MASTER=${master}" >> ${networkpath}/ifcfg-$ipDevice
     [ -n "$slave" ] &&  echo "SLAVE=${slave}"   >> ${networkpath}/ifcfg-$ipDevice
     [ -n "$bridge" ] && echo "BRIDGE=${bridge}" >> ${networkpath}/ifcfg-$ipDevice
  fi

  local propertynames=$(echo "$properties" | sed -e 's/=\"[^"]*\"//g' -e "s/=\'[^']*\'//g" -e 's/=\S*//g')
  eval "$properties"
  
  for property in $propertynames; do
  	echo "$property=\""$(eval echo \$$property)"\"" >> ${networkpath}/ifcfg-$ipDevice
  done
  return 0
}
#************ rhel6_ip2Config

#****f* rhel6/network-lib/rhel6_get_networkpath
#  NAME
#    rhel6_get_networkpath
#  SYNOPSIS
#    function rhel6_get_networkpath()
#  MODIFICATION HISTORY
#  IDEAS
#    returns distribution dependent the path to the network configuration files
#  SOURCE
#
rhel6_get_networkpath() {
	echo "/etc/sysconfig/network-scripts"
}
#************ rhel6_get_networkpath
