#
# $Id: boot-lib.sh,v 1.5 2009/10/07 12:07:07 marc Exp $
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
  is_mounted $chroot_path/dev || exec_local mount -t tmpfs none $chroot_path/dev

  exec_local cp -a /dev $chroot_path/
  is_mounted $chroot_path/dev/pts || exec_local mount -t devpts none $chroot_path/dev/pts
  is_mounted $chroot_path/proc || exec_local mount -t proc proc $chroot_path/proc
  is_mounted $chroot_path/sys || exec_local mount -t sysfs sysfs $chroot_path/sys
}
#************ create_chroot

#****f* boot-lib.sh/rhel6_detectHalt
#  NAME
#    rhel6_detectHalt build a chroot environment
#  SYNOPSIS
#    function rhel6_detectHalt($xkillall_procsfile, $rootfss) {
#  MODIFICATION HISTORY
#  USAGE
#  rhel6_detectHalt
#  IDEAS
#
#  SOURCE
#
rhel6_detectHalt() {
    local runlevel2=$1
    local command="halt -p"
    [ -z "$runlevel2" ] && runlevel2=0
    
    if [ $runlevel2 -eq 0 ]; then # case halt
    	command="halt"
    elif [ $runlevel2 -eq 6 ]; then
        command="reboot"
    fi
    HALTARGS="-d"
    [ "$INIT_HALT" != "HALT" ] && HALTARGS="$HALTARGS -p"

    echo $command $HALTARGS
}
#************** rhel6_detectHalt

