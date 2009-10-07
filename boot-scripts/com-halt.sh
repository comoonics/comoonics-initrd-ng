#!/bin/bash
#
# $Id: com-halt.sh,v 1.5 2009-10-07 11:41:16 marc Exp $
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
#    $Id: com-halt.sh,v 1.5 2009-10-07 11:41:16 marc Exp $
#  DESCRIPTION
#    script called from /etc/init.d/halt
#  USAGE
#    com-halt.sh chrootpath haltcmd
#*******

# include libraries
predir=/opt/atix/comoonics-bootimage/boot-scripts
source ${predir}/etc/std-lib.sh
sourceLibs ${predir}

CHROOT_PATH=$(/opt/atix/comoonics-bootimage/manage_chroot.sh -p)

if [ -n "$CHROOT_PATH" ] && [ -d $CHROOT_PATH/mnt/newroot ]; then
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

  if [ $# -eq 0 ]; then
    #FIXME: the following should be distribution dependent.
    echo_local -n "Detecting power cycle type (actlevel=$actlevel)"
    cmd=$(detectHalt "$actlevel" . /mnt/newroot)
    return_code $?
  else
    cmd=$@
  fi
  #mkdir -p $CHROOT_PATH/mnt/newroot
  exec chroot . ./com-realhalt.sh -r /mnt/newroot $cmd
fi
####################
# $Log: com-halt.sh,v $
# Revision 1.5  2009-10-07 11:41:16  marc
# - added initEnv for nice UI
# - added parameters to make detectHalt more generic
#
# Revision 1.4  2009/09/28 13:09:02  marc
# - Implemented new way to also use com-halt as halt.local either in /sbin or /etc/init.d dependent on distribution
#
# Revision 1.3  2008/10/14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#