#
# $Id: network-lib.sh,v 1.2 2007-12-07 16:40:00 reiner Exp $
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

#****f* boot-lib.sh/suse_ip2Config
#  NAME
#    suse_ip2Config
#  SYNOPSIS
#    function suse_ip2Config(ipDevice, ipAddr, ipGate, ipNetmask, ipHostname) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function suse_ip2Config() {
  local ipDevice=$1
  local ipAddr=$2
  local ipGate=$3
  local ipNetmask=$4
  local ipHostname=$5

  awkfile="/etc/sysconfig/network/ifcfg.template.awk"
  # just for testing
  local __prefix="/tmp"

  if [ -z "$ipHostname" ]; then hostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then 
    bootproto="dhcp"
  else 
    bootproto="static"
  fi

  if [ "$ipAddr" != "dhcp" ]; then 
      hostname=$(expr match "$ipAddr" '\([^.]*\).')
      domainname=$(expr match "$ipAddr" '[^.]*.\(.*\)$')
  
      /bin/hostname $hostname
      /bin/domainname $domainname
      echo $hostname > /etc/HOSTNAME
      echo $domainname > /etc/defdomain
  fi

  awk -F'=' bootproto="$bootproto" ipaddr="$ipAddr" netmask="$ipNetmask" startmode="onboot" '
BEGIN {
  for (i=1; i < ARGC; i++) {
    split(ARGV[i], value_pair, "=");
    printf("%s=%s\n", toupper(value_pair[1]), value_pair[2]);
  }
}
'> /etc/sysconfig/network/ifcfg-$ipDevice
  if [ "$ipAddr" != "dhcp" ]; then 
      echo "default $ipGate - -" >> /etc/sysconfig/network/routes
      echo_local_debug "2.1.2 /etc/sysconfig/network-scripts/routes"
      exec_local_debug cat /etc/sysconfig/network/routes
  fi

  echo_local_debug "2.1.1 /etc/sysconfig/network/ifcfg-$ipDevice"
  exec_local_debug cat /etc/sysconfig/network/ifcfg-$ipDevice
  return 0
}
#************ suse_ip2Config 


#################
# $Log: network-lib.sh,v $
# Revision 1.2  2007-12-07 16:40:00  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
