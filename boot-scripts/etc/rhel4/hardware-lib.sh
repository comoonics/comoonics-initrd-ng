#
# $Id: hardware-lib.sh,v 1.7 2009-02-27 08:38:22 marc Exp $
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
#****h* boot-scripts/etc/rhel4/hardware-lib.sh
#  NAME
#    hardware-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for hardware support functions for Red Hat 
#    Enterprise Linux 4.
#*******

#****f* hardware-lib.sh/rhel4_hardware_detect
#  NAME
#    rhel4_hardware_detect
#  SYNOPSIS
#    function rhel4_hardware_detect()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function rhel4_hardware_detect() {
  cp ${modules_conf} ${modules_conf}.tmpl
  exec_local /usr/sbin/kudzu -t 30 -c SCSI -q 
  mv ${modules_conf} ${modules_conf}.scsi
  cp ${modules_conf}.tmpl ${modules_conf}
  #exec_local /usr/sbin/kudzu -t 30 -c RAID -q 
  #mv ${modules_conf} ${modules_conf}.raid
  exec_local /usr/sbin/kudzu -t 30 -c USB -q 
  mv ${modules_conf} ${modules_conf}.usb
  cp ${modules_conf}.tmpl ${modules_conf}
  exec_local /usr/sbin/kudzu -t 30 -c NETWORK -q
  cat ${modules_conf}.scsi >> ${modules_conf}
  #	cat ${modules_conf}.raid >> ${modules_conf}
  cat ${modules_conf}.usb >> ${modules_conf}
  cp ${modules_conf} ${modules_conf}.tmpl
  cat ${modules_conf}.tmpl | sort -u > ${modules_conf}

  for driver in $( awk '$2 ~ /^eth/ { print $3; }' < ${modules_conf} | sort -u); do
  	exec_local modprobe $driver
  done
  unset driver

  return $return_c
}
#************ rhel4_hardware_detect 

#****f* hardware-lib.sh/rhel4_udev_start
#  NAME
#    udev_start
#  SYNOPSIS
#    function boot-lib.sh/rhel4_udev_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function rhel4_udev_start() {
	killall -0 udevd || $(udevd &)
    /sbin/udevstart.static
}
#************rhel4_udev_start

#############
# $Log: hardware-lib.sh,v $
# Revision 1.7  2009-02-27 08:38:22  marc
# backport to rhel4
#
# Revision 1.6  2008/08/14 13:32:46  marc
# - rewrote udevstart because would not work with kvm
#
# Revision 1.5  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.4  2007/09/07 07:58:35  mark
# added udev_start method
#
# Revision 1.3  2006/07/03 08:33:26  marc
# changed hardwaredetection
#
# Revision 1.2  2006/05/12 13:06:41  marc
# First stable Version 1.0 for initrd.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
