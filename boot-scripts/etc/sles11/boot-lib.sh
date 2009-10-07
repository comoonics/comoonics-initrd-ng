#
# $Id: boot-lib.sh,v 1.2 2009-10-07 12:05:28 marc Exp $
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

#****f* boot-lib.sh/sles11_detectHalt
#  NAME
#    sles11_detectHalt build a chroot environment
#  SYNOPSIS
#    function sles11_detectHalt($xkillall_procsfile, $rootfss) {
#  MODIFICATION HISTORY
#  USAGE
#  sles11_detectHalt
#  IDEAS
#
#  SOURCE
#
sles11_detectHalt() {
    local runlevel2=$1
    local command="halt -p"
    local newroot=$2
    local oldroot=$3
    [ -z "$runlevel2" ] && runlevel2=0
    local arch
    local opts
    
    [ -f $oldroot/etc/sysconfig/boot ] && . $oldroot/etc/sysconfig/boot
    [ -f $oldroot/etc/sysconfig/boot ] && . $oldroot/etc/sysconfig/shutdown
    
    if [ $runlevel2 -eq 0 ]; then # case halt
        arch=$(/bin/uname -m)
        command="halt"
        mddev=""
        opts=""
        #
        # Sysvinit's shutdown is knowning about the option -P and -H to set
        # the environment variable INIT_HALT within init for the runlevel 0.
        # If this variable is not set we use the system default.
        #
        if test -z "$INIT_HALT" ; then
            case "$HALT" in
            [Pp]*) INIT_HALT=POWEROFF ;;
            [Hh]*) INIT_HALT=HALT     ;;
            *) 
                INIT_HALT=POWEROFF
                #
                # Check this if valid for AMD/Intel based systems
                #
                case "$arch" in
                i?86|x86_64)
                    if test -e /proc/apm -o -e /proc/acpi -o -e /proc/sys/acpi ; then
                        INIT_HALT=POWEROFF
                    else
                        INIT_HALT=HALT
                        case "$(rc_cmdline apm)" in
                        apm=smp-power-off|apm=power-off) INIT_HALT=POWEROFF ;;
                        esac
                    fi
                    ;;
                esac
                ;;
            esac
        fi
        #
        # The manual page of shutdown utilizes POWEROFF whereas in
        # the code the word POWERDOWN shows up for the option -P.
        #
        case "$INIT_HALT" in
        POWEROFF|POWERDOWN)
            opts="${opts:+$opts }-p" ;;
        esac
        #
        # Sometimes wake-on-lan isn't wanted, if so stop network
        #
        if test "$HALT_NETWORK" = "yes" ; then
            opts="${opts:+$opts }-i"
        fi
        #
        # Sometimes it is wanted to stop also the disks
        #
        if test "$HALT_DISKS" = "yes" ; then
            opts="${opts:+$opts }-h"
        fi
    elif [ $runlevel2 -eq 6 ]; then
        command="reboot"
        mddev=""
        opts="-i"
    fi
    echo $command -d -f -n $opts
}
#************** sles11_detectHalt

