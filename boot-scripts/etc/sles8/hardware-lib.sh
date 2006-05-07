#
# $Id: hardware-lib.sh,v 1.1 2006-05-07 11:33:40 marc Exp $
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
function suse_hardware_detect() {
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
    
	if [ -n "$alias" ]; then
	    cp /etc/modules.conf /etc/modules.conf.bak
	    echo_local "   suse_hwscan: registering alias \"$alias\" to module \"$module\"..."
	    cat /etc/modules.conf.bak | awk -v alias="$alias$index" -v module="$module" '
$1 == "alias" && $2 == alias {
   print "alias", alias, module;
   alias_set=1;
   next;
}
{ print; }
END {
  if (!alias_set) {
     print "alias", alias, module;
  }
}
' > /etc/modules.conf
	fi
	let lines="$lines-3"
	hwinfo=$(echo "$hwinfo" | tail -n $lines)
	let index++
    done
}
#************ suse_hardware_detect_ 

#****f* boot-scripts/etc/sles8/suse_hwscan
#  NAME
#    suse_hwscan
#  SYNOPSIS
#    function suse_hwscan() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function suse_hardware_detect() {
    echo_local "HWSCAN: Detecting scsi-controller: "
    exec_local suse_hwconfig "scsi-controller" "storage-ctrl" "scsi-hostadapter"
    echo_local "HWSCAN: Detecting NIC: "
    exec_local suse_hwconfig "nic" "netcard" "eth"
}
#************ suse_hwscan 

#############
# $Log: hardware-lib.sh,v $
# Revision 1.1  2006-05-07 11:33:40  marc
# initial revision
#
