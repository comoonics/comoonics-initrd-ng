#
# $Id: xen-lib.sh,v 1.1 2007-10-05 10:08:25 marc Exp $
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
  if ! [ -d /etc/xen ]; then
  	echo_local "WARNING XEN DETECTED BUT NO EXTRAFILES FOUND."
  	echo_local "You might want to install comoonics-bootimage-extras-xen to have full support"
  fi
  dmesg | grep -A1 BIOS | tail -1 | grep "[[:space:]]Xen" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
  	return 1
  fi
  dmesg | grep -i xen >/dev/null 2>&1
  return $?
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
  if ! [ -d /etc/xen ]; then
  	echo_local "WARNING XEN DETECTED BUT NO EXTRAFILES FOUND."
  	echo_local "You might want to install comoonics-bootimage-extras-xen to have full support"
  fi
  dmesg | grep -A1 BIOS | tail -1 | grep "[[:space:]]Xen" >/dev/null 2>&1
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