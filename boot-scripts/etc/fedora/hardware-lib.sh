#
# $Id: hardware-lib.sh,v 1.2 2009-01-29 15:55:16 marc Exp $
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
function fedora9_hardware_detect() {
  exec_local udev_start
  [ -e /proc/modules ] && stabilized --type=hash --interval=600 --good=5 /proc/modules

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
function fedora9_udev_start() {
	if ! /sbin/pidof udevd > /dev/null; then
#      /sbin/modprobe sd_mod
#      /sbin/modprobe sg

      udevd -d # &&
#	  udevtrigger
	else
      udevtrigger
	fi
}
#************rhel5_udev_start

#****f* hardware-lib.sh/rhel5_udev_start
#  NAME
#    udev_start
#  SYNOPSIS
#    function boot-lib.sh/rhel5_udev_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function fedora9_udev_stop() {
	if /sbin/pidof udevd > /dev/null; then
		kill $(/sbin/pidof udevd)
	else
	    true
	fi
    
}
#************rhel5_udev_start

#############
# $Log: hardware-lib.sh,v $
# Revision 1.2  2009-01-29 15:55:16  marc
# Implemented new hw detection
#
# Revision 1.1  2009/01/28 12:45:29  marc
# initial revision.
# Support for fedora
#
# Revision 1.7  2008/11/18 08:37:56  marc
# cosmetic change.
#
# Revision 1.6  2008/08/14 13:31:23  marc
# - modified hardware detection
#
# Revision 1.5  2008/01/24 13:34:56  marc
# - BUG#170, udev with dm-multipath and RHEL5 is not working. reviewed the udev and stabilized more often
#
# Revision 1.4  2007/12/18 08:43:35  mark
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
