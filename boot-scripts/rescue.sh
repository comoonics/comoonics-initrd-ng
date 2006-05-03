#!/bin/bash

# $Id: rescue.sh,v 1.2 2006-05-03 12:45:35 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
# Saves the bootlog-file to disk
#****h* comoonics-bootimage/rescue.sh
#  NAME
#    rescue.sh
#    $Id: rescue.sh,v 1.2 2006-05-03 12:45:35 marc Exp $
#  DESCRIPTION
#    Rescue script that is called whenever the initrd ends in errors 
#    and cannot continue
#*******

#****f* rescue.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#

source /etc/boot-lib.sh

echo_local "RESCUE: Something was not as expected saving the logfile to disk"
echo_local "        or rescue/function test mode was switched on."
echo_local "PLEASE SEND DISK TO:"
cat /etc/atix.txt

echo_local "Insert floppy into your floppy drive and"
echo_local -n "Press <Y> to continue: "
read yes

if [ "$yes" = "Y" -o "$yes" = "y" ]; then
   echo_local "Saving logfiles..."
   exec_local /bin/tar cvf $diskdev /var/log/comoonics*
fi
#********** main

###################
# $Log: rescue.sh,v $
# Revision 1.2  2006-05-03 12:45:35  marc
# added documentation
#
