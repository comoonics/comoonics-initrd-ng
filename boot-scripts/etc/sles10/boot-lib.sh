#
# $Id: boot-lib.sh,v 1.2 2009-04-14 14:49:22 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
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
#  exec_local mount --bind /dev $chroot_path/dev
  exec_local cp -a /dev $chroot_path/
  exec_local mount -t devpts none $chroot_path/dev/pts
  exec_local mount -t proc proc $chroot_path/proc
  exec_local mount -t sysfs sysfs $chroot_path/sys
}
#************ create_chroot

