#!/bin/bash
#
# $Id: com-halt.sh,v 1.2 2007-12-07 16:39:59 reiner Exp $
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
#    $Id: com-halt.sh,v 1.2 2007-12-07 16:39:59 reiner Exp $
#  DESCRIPTION
#    script called from /etc/init.d/halt
#  USAGE
#    com-halt.sh chrootpath haltcmd
#*******

CHROOT_PATH=$(dirname $0)

cd $CHROOT_PATH
#mkdir -p $CHROOT_PATH/mnt/newroot
/sbin/pivot_root . ./mnt/newroot
chroot . ./com-realhalt.sh -r /mnt/newroot $*


