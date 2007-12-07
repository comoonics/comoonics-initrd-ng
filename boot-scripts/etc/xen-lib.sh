#
# $Id: xen-lib.sh,v 1.5 2007-12-07 16:39:59 reiner Exp $
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

#****f* boot-lib.sh/xen_domx_detect
#  NAME
#    xen_domx_detect
#  SYNOPSIS
#    function xen_domx_detect()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function xen_domx_detect() {
  dmesg | grep -A1 BIOS | tail -1 | grep "[[:space:]]Xen" >/dev/null 2>&1
}
#************ xen_domx_detect

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
  dmesg | grep -A1 BIOS | tail -1 | grep "[[:space:]]Xen" >/dev/null 2>&1
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
#************ xen_domx_detect

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
  dmesg | grep -A1 BIOS | tail -1 | grep "[[:space:]]Xen" >/dev/null 2>&1
  _err=$?
  if [ $_err -eq 0 ] && ! [ -d /etc/xen ]; then
  	echo_local "WARNING XEN DETECTED BUT NO EXTRAFILES FOUND."
  	echo_local "You might want to install comoonics-bootimage-extras-xen to have full support"
  	_err=1
  fi
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
}
#************ xen_domx_hardware_detect

#****f* boot-lib.sh/xen_nic_post
#  NAME
#    xen_nic_post
#  SYNOPSIS
#    function xen_nic_post()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function xen_nic_post() {
	local nic=$1
	local number=${nic:3}
	[ -z "$number" ] && number="0"
	modprobe netloop &&
	/etc/xen/scripts/network-bridge start vifnum=$number
}