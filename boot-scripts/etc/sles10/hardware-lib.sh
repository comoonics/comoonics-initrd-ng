#
# $Id: hardware-lib.sh,v 1.1 2008-08-14 13:30:52 marc Exp $
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
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output
#****h* boot-scripts/etc/sles8/hardware-lib.sh
#  NAME
#    hardware-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for hardware support functions for SuSE 
#    distributions.
#*******

#****f* boot-scripts/etc/sles8/suse_hardware_detect
#  NAME
#    suse_hardware_detect
#  SYNOPSIS
#    function suse_hardware_detect() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function suse_hwconfig() {
    local name=$1
    local hwinfo_type=$2
    local alias=$3
    local hwinfo=$(hwinfo --$hwinfo_type | grep "Driver Info #0" -A2)
    local index=0
    while [ -n "$hwinfo" ]; do
		lines=$(echo "$hwinfo" | wc -l)
		local cmd=$(echo "$hwinfo" | grep "Driver Activation Cmd" | head -n1 | awk -F ':' '{ match($2, "\"([^\"]+)\"", cmd); print $1, cmd[1];}');
		local module=$(echo "$hwinfo" | grep "Driver Status" | head -n1 | awk -F ':' '{ print $2;}' | awk '{print $1;}');
		echo_local "   suse_hwscan: loading $name ($hwinfo_type/$module)..."
		exec_local modprobe $cmd
    
#		if [ -n "$alias" ]; then
#			cp /etc/modules.conf /etc/modules.conf.bak
#			echo_local "   suse_hwscan: registering alias \"$alias\" to module \"$module\"..."
#			cat /etc/modules.conf.bak | awk -v alias="$alias$index" -v module="$module" '
#					$1 == "alias" && $2 == alias {
#	   				print "alias", alias, module;
#   					alias_set=1;
#   					next;
#				}
#				{ print; }
#				END {
#  					if (!alias_set) {
#     					print "alias", alias, module;
#  					}
#				}
#			' > /etc/modules.conf
#		fi
		let lines="$lines-3"
		hwinfo=$(echo "$hwinfo" | tail -n $lines)
		let index++
    done
}
#************ suse_hardware_detect_ 

#****f* boot-scripts/etc/sles10/sles10_hardware_detect
#  NAME
#    suse_hwscan
#  SYNOPSIS
#    function sles10_hardware_detect() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function sles10_hardware_detect() {
    echo_local "HWSCAN: Detecting scsi-controller: "
    exec_local suse_hwconfig "scsi-controller" "storage-ctrl" "scsi-hostadapter"
    echo_local "HWSCAN: Detecting NIC: "
    exec_local suse_hwconfig "nic" "netcard" "eth"
}
#************ sles10_hardware_detect

#****f* hardware-lib.sh/sles10_udev_start
#  NAME
#    udev_start
#  SYNOPSIS
#    function boot-lib.sh/sles10_udev_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function sles10_udev_start() {
	if ! killall -0 udevd; then
		udevd -d &&
		udevtrigger
	else
		udevtrigger
	fi
    
}
#************sles10_udev_start

#############
# $Log: hardware-lib.sh,v $
# Revision 1.1  2008-08-14 13:30:52  marc
# initial revision
#
# Revision 1.2  2007/12/07 16:40:00  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
