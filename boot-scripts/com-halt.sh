#!/bin/bash
#
# $Id: com-halt.sh,v 1.9 2010-08-26 12:18:02 marc Exp $
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
#****h* comoonics-bootimage/com-halt.sh
#  NAME
#    com-halt.sh
#    $Id: com-halt.sh,v 1.9 2010-08-26 12:18:02 marc Exp $
#  DESCRIPTION
#    script called from /etc/init.d/halt
#  USAGE
#    com-halt.sh chrootpath haltcmd
#*******

CHROOT_PATH=$(/opt/atix/comoonics-bootimage/manage_chroot.sh -p 2>/dev/null)

if [ -n "$CHROOT_PATH" ] && [ -d $CHROOT_PATH/mnt/newroot ]; then
  # With SLES at this stage there might be /proc and /sys already umounted so we'll remount it
  mount 2>/dev/null | grep '[[:space:]]/proc[[:space:]]' > /dev/null
  if [ $? -ne 0 ]; then
  	mount -t proc none /proc 2>/dev/null
  fi
  mount 2>/dev/null | grep '[[:space:]]/sys[[:space:]]' > /dev/null
  if [ $? -ne 0 ]; then
  	mount -t sysfs none /sys 2>/dev/null
  fi
  # First check for the chroot environment being mounted as ro
  mount -o remount,rw $CHROOT_PATH &>/dev/null
  mount -o remount,rw / &>/dev/null
  
  # include libraries
  predir=/opt/atix/comoonics-bootimage/boot-scripts
  source ${predir}/etc/std-lib.sh
  sourceLibs ${predir}
  repository_has_key rootfs && [ clusterfs_chroot_needed -ne 0 ] && exit 0 
  initEnv
  actlevel=$(runlevel | awk '{ print $2;}')
  	
  cd $CHROOT_PATH
  /sbin/pivot_root . ./mnt/newroot

  echo_local -n "Scanning for Bootparameters..."
  getParameter newroot "/mnt/newroot" &>/dev/null &&
  getParameter cluster_conf $cluster_conf &>/dev/null &&
  getParameter debug $debug &>/dev/null &&
  getParameter step $stepmode &>/dev/null &&
  getParameter dstep $dstepmode &>/dev/null &&
  getParameter nousb &>/dev/null &&
  return_code 0
  echo_local -N

  if [ $# -eq 0 ]; then
    #FIXME: the following should be distribution dependent.
    echo_local -n "Detecting power cycle type (actlevel=$actlevel)"
    cmd=$(detectHalt "$actlevel" . /mnt/newroot)
    return_code $?
    echo_local -N
  else
    cmd=$@
  fi
  #mkdir -p $CHROOT_PATH/mnt/newroot
  exec chroot . ./com-realhalt.sh -r /mnt/newroot $cmd
fi
####################
# $Log: com-halt.sh,v $
# Revision 1.9  2010-08-26 12:18:02  marc
# - always secure that /proc and /sys are mounted
#
# Revision 1.8  2010/02/21 12:05:19  marc
# kicked an old bash
#
# Revision 1.7  2010/02/16 10:04:49  marc
# - remount / and chroot rw if they were mounted ro.
#
# Revision 1.6  2010/02/15 14:05:53  marc
# remount chroot rw
#
# Revision 1.5  2009/10/07 11:41:16  marc
# - added initEnv for nice UI
# - added parameters to make detectHalt more generic
#
# Revision 1.4  2009/09/28 13:09:02  marc
# - Implemented new way to also use com-halt as halt.local either in /sbin or /etc/init.d dependent on distribution
#
# Revision 1.3  2008/10/14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#