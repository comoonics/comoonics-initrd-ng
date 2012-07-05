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

if [ -n "$CHROOT_PATH" ] && [ -d "$CHROOT_PATH/mnt/newroot" ]; then
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
  repository_has_key rootfs && clusterfs_chroot_needed || { echo_local "No chroot needed exiting this process."; exit 0; } 
  initEnv
  actlevel=$(runlevel | awk '{ print $2;}')
  	
  cd $CHROOT_PATH
  /sbin/pivot_root . ./mnt/newroot

  echo_local -n "Scanning for Bootparameters..."
  getParameter newroot "/mnt/newroot" &>/dev/null &&
  getParameter debug $debug &>/dev/null &&
  getParameter step $stepmode &>/dev/null &&
  getParameter dstep $dstepmode &>/dev/null &&
  getParameter nousb &>/dev/null &&
  return_code 0
  echo_local -N

  if [ $# -eq 0 ]; then
    #FIXME: the following should be distribution dependent.
    echo_local -n "Detecting power cycle type (actlevel=$actlevel)"
    cmd=$(detectHalt "$actlevel" . $(repository_get_value newroot))
    return_code $?
    echo_local -N
  else
    opts=
    [ -n "$2" ] && opts=$2
    [ -n "$4" ] && cmd="$4 $opts"
    [ -z "$cmd" ] && [ -n "$1" ] && cmd="$1"
  fi
  #mkdir -p $CHROOT_PATH/mnt/newroot
  exec chroot . ./com-realhalt.sh -r $(repository_get_value newroot) $cmd
fi
