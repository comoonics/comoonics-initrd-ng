#
# $Id: boot-lib.sh,v 1.7 2009-10-07 12:06:40 marc Exp $
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
  is_mounted $chroot_path/dev || exec_local mount -t tmpfs none $chroot_path/dev
#  exec_local mount --bind /dev $chroot_path/dev
  exec_local cp -a /dev $chroot_path/
  is_mounted $chroot_path/dev/pts || exec_local mount -t devpts none $chroot_path/dev/pts
  is_mounted $chroot_path/proc || exec_local mount -t proc proc $chroot_path/proc
  is_mounted $chroot_path/sys || exec_local mount -t sysfs sysfs $chroot_path/sys
}
#************ create_chroot

#****f* boot-lib.sh/rhel5_detectHalt
#  NAME
#    rhel5_detectHalt build a chroot environment
#  SYNOPSIS
#    function rhel5_detectHalt($xkillall_procsfile, $rootfss) {
#  MODIFICATION HISTORY
#  USAGE
#  rhel5_detectHalt
#  IDEAS
#
#  SOURCE
#
rhel5_detectHalt() {
    local runlevel2=$1
    local newroot=$2
    local oldroot=$3
    
    local command="halt -p"
    [ -z "$runlevel2" ] && runlevel2=0
    
    if [ $runlevel2 -eq 0 ]; then # case halt
    	command="halt"
    elif [ $runlevel2 -eq 6 ]; then
        command="reboot"
    fi
    HALTARGS="-d"
    [ -f /poweroff -o ! -f /halt ] && HALTARGS="$HALTARGS -p"

    echo $command $HALTARGS
}
#************** rhel5_detectHalt

#################
# $Log: boot-lib.sh,v $
# Revision 1.7  2009-10-07 12:06:40  marc
# - accepting more arguments to be passed to detectHalt
# - detection of already mounted fs in create_chroot
#
# Revision 1.6  2009/09/28 12:44:14  marc
# Added exitrd function rhel5_detectHalt
#
# Revision 1.5  2009/08/11 09:52:17  marc
# Fixed bug #356 Device changes not applied in chroot environment when chroot on local disk
#
# Revision 1.4  2009/04/14 14:49:22  marc
# sys=>sysfs
#