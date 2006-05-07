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
# Revision 1.1  2006-05-07 11:33:40  marc
# initial revision
#
