#
# $Id: hardware-lib.sh,v 1.4 2007-12-18 08:43:35 mark Exp $
#
# @(#)$File$
#
# Copyright (c) 2007 ATIX GmbH.
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
#****h* boot-scripts/etc/rhel5/hardware-lib.sh
#  NAME
#    hardware-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for hardware support functions for Red Hat
#    Enterprise Linux 5.
#*******

#****f* hardware-lib.sh/rhel5_hardware_detect
#  NAME
#    rhel5_hardware_detect
#  SYNOPSIS
#    function rhel5_hardware_detect()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function rhel5_hardware_detect() {
  local KUDZU="/sbin/kudzu"
  cp ${modules_conf} ${modules_conf}.tmpl
  exec_local $KUDZU -t 30 -c SCSI -q
  mv ${modules_conf} ${modules_conf}.scsi
  cp ${modules_conf}.tmpl ${modules_conf}
  #exec_local $KUDZU -t 30 -c RAID -q
  #mv ${modules_conf} ${modules_conf}.raid
  exec_local $KUDZU -t 30 -c USB -q
  mv ${modules_conf} ${modules_conf}.usb
  cp ${modules_conf}.tmpl ${modules_conf}
  exec_local $KUDZU -t 30 -c NETWORK -q
  cat ${modules_conf}.scsi >> ${modules_conf}
  #	cat ${modules_conf}.raid >> ${modules_conf}
  cat ${modules_conf}.usb >> ${modules_conf}
  cp ${modules_conf} ${modules_conf}.tmpl
  cat ${modules_conf}.tmpl | sort -u > ${modules_conf}

  return $return_c
}
#************ rhel5_hardware_detect

#****f* hardware-lib.sh/rhel5_udev_start
#  NAME
#    udev_start
#  SYNOPSIS
#    function boot-lib.sh/rhel5_udev_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function rhel5_udev_start() {
	if ! /sbin/pidof udevd; then
		udevd -d &&
		udevtrigger
	else
		/bin/true
	fi
    
}
#************rhel4_udev_start

#############
# $Log: hardware-lib.sh,v $
# Revision 1.4  2007-12-18 08:43:35  mark
# resolve bz 170
#
# Revision 1.3  2007/10/02 12:06:36  marc
# cosmetic-changes
#
# Revision 1.2  2007/10/02 11:51:48  mark
# fixes typo in comment
#
# Revision 1.1  2007/09/07 07:57:55  mark
# initial check in
#
