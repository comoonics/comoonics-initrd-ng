#!/bin/bash
#
# $Id: com-halt.sh,v 1.3 2008-10-14 10:57:07 marc Exp $
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
#    $Id: com-halt.sh,v 1.3 2008-10-14 10:57:07 marc Exp $
#  DESCRIPTION
#    script called from /etc/init.d/halt
#  USAGE
#    com-halt.sh chrootpath haltcmd
#*******

CHROOT_PATH=$(dirname $0)

cd $CHROOT_PATH
#mkdir -p $CHROOT_PATH/mnt/newroot
if [ -d ./mnt/newroot ]; then
  /sbin/pivot_root . ./mnt/newroot
  chroot . ./com-realhalt.sh -r /mnt/newroot $*
fi

####################
# $Log: com-halt.sh,v $
# Revision 1.3  2008-10-14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#