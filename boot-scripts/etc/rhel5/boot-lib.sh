#
# $Id: boot-lib.sh,v 1.8 2009-12-09 09:07:41 marc Exp $
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
