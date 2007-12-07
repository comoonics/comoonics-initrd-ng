#!/bin/bash

# $Id: rescue.sh,v 1.3 2007-12-07 16:39:59 reiner Exp $
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
# Saves the bootlog-file to disk
#****h* comoonics-bootimage/rescue.sh
#  NAME
#    rescue.sh
#    $Id: rescue.sh,v 1.3 2007-12-07 16:39:59 reiner Exp $
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
# Revision 1.3  2007-12-07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.2  2006/05/03 12:45:35  marc
# added documentation
#
