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

