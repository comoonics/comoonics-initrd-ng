#
# $Id: xen-lib.sh,v 1.9 2009-02-25 10:36:59 marc Exp $
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

#****f* boot-lib.sh/xen_dom0_detect
#  NAME
#    xen_dom0_detect
#  SYNOPSIS
#    function xen_dom0_detect()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function xen_dom0_detect() {
  local _err=0
  if [ ! -e /proc/xen ]; then
  	return 1
  fi
  xen_domx_detect
  if [ $? -eq 0 ]; then
  	return 1
  fi
  dmesg | grep -i xen >/dev/null 2>&1
  _err=$?
  if [ $_err -eq 0 ] && ! [ -d /etc/xen ]; then
  	echo_local "WARNING XEN DETECTED BUT NO EXTRAFILES FOUND."
  	echo_local "You might want to install comoonics-bootimage-extras-xen to have full support"
  	_err=1
  fi
  return $_err
}
#************ xen_dom0_detect

#****f* boot-lib.sh/xen_domx_detect
#  NAME
#    xen_detect
#  SYNOPSIS
#    function xen_domx_detect()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function xen_domx_detect() {
  local _err=0
  dmesg | grep -A1 BIOS | tail -1 | grep "[[:space:]]Xen" >/dev/null 2>&1 || dmesg | grep "Xen reported:.*processor" >/dev/null 2>&1
  _err=$?

  if [ $_err -eq 0 ] && ! [ -d /etc/xen ]; then
    _err=0
  else
    _err=1
  fi
#  	echo_local "WARNING XEN DETECTED BUT NO EXTRAFILES FOUND."
#  	echo_local "You might want to install comoonics-bootimage-extras-xen to have full support"
#  	_err=1
#  fi
  return $_err
}
#************ xen_domx_detect

#****f* boot-lib.sh/xen_hardware_detect
#  NAME
#    xen_domx_hardware_detect
#  SYNOPSIS
#    function xen_domx_hardware_detect()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function xen_domx_hardware_detect() {
  (for i in $(seq 0 9); do
    echo "alias eth$i xennet"
   done
   echo "alias scsi_hostadapter xenblk") > ${modules_conf}
  exec_local modprobe xennet
}
#************ xen_domx_hardware_detect

#****f* boot-lib.sh/xen_ip2Config
#  NAME
#    xen_ip2Config
#  SYNOPSIS
#    function xen_ip2Config()
#  DESCRIPTION
#    Creates the appropriate Network konfiguration for XEN (Brigde from physical interface to
#    the bridged physical interface). Only for nics with ips.
#  SOURCE
#
function xen_ip2Config() {
  local ipAddr=$(getPosFromIPString 1, $1)
  local ipDevice=$(getPosFromIPString 6, $1)
  local bridge=$(getPosFromIPString 8, $1)

  echo "$ipAddr" | grep "[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*.[[:digit:]][[:digit:]]*" </dev/null 2>&1
  if [ -n "$ipAddr" ] && [ "${ipDevice:0:1}" != "p" ] && [ -z "$bridge" ]; then
    local ipGate=$(getPosFromIPString 3, $1)
    local ipNetmask=$(getPosFromIPString 4, $1)
    local ipHostname=$(getPosFromIPString 5, $1)
    local ipMAC=$(getPosFromIPString 7, $1)
    local master=$(getPosFromIPString 2, $1)
    local slave=$(getPosFromIPString 3, $1)
    local bridgeDevice=$ipDevice
    local bridgeMAC=$ipMAC

	# First the bridge..
    #exec_local ip2Config "" "" "" "" "$ipDevice" "" "$ipMAC" "$master" "$slave" "$bridgeDevice"
    # Then the bridged device
    ip2Config "$ipAddr" "$ipGate" "$ipNetmask" "$ipHostname"  "$bridgeDevice" "$bridgeMAC" "$master" "$slave"
  else
    ip2Config $1
  fi
}
#************ xen_ip2Config

