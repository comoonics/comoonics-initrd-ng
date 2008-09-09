#
# $Id: boot-lib.sh,v 1.3.2.1 2008-09-09 15:04:15 mark Exp $
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

#
#****h* comoonics-bootimage/boot-lib.sh
#  NAME
#    boot-lib.sh
#    $id$
#  DESCRIPTION
#*******

#****f* boot-lib.sh/create_chroot
#  NAME
#    create_chroot build a chroot environment
#  SYNOPSIS
#    function create_chroot($chroot_source $chroot_path) {
#  MODIFICATION HISTORY
#  USAGE
#  create_chroot
#  IDEAS
#
#  SOURCE
#
function create_chroot () {
  chroot_source=$1
  chroot_path=$2

  exec_local cp -axf $chroot_source $chroot_path
  exec_local rm -rf $chroot_path/var/run/*
  exec_local mkdir -p $chroot_path/tmp
  exec_local chmod 755 $chroot_path
  #exec_local mount --bind /dev $chroot_path/dev
  exec_local cp -a /dev/* $chroot_path/dev/
  exec_local mount -t devpts none $chroot_path/dev/pts
  exec_local mount -t proc proc $chroot_path/proc
  exec_local mount -t sysfs none $chroot_path/sys
}
#************ create_chroot

