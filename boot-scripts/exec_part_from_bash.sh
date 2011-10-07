#!/bin/bash
#****h* comoonics-bootimage/exec_part_from_bash.sh
#  NAME
#    exec_part_from_bash.sh
#    $Id: exec_part_from_bash.sh,v 1.6 2007-12-07 16:39:59 reiner Exp $
#  DESCRIPTION
#    helperskript for testing every script for the 
#    comoonics-bootimage in the running initrd
#*******

#
# $Id: exec_part_from_bash.sh,v 1.6 2007-12-07 16:39:59 reiner Exp $
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
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    bootpart=...          Which linuxrc.{bootpart} file should be loaded into 
#                  that script.
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output
#
# Marc Grimme: existence of /etc/gfs-lib.sh with all gfs-functions. 
#         Should be the framework for all other functionalities as well.

#****f* exec_part_from_bash.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
echo "Starting ATIX $0"
echo 'Version $Date: 2007-12-07 16:39:59 $'


. etc/sysconfig/comoonics

# initstuff is done in here
source /etc/boot-lib.sh

initBootProcess

# network parameters
getNetParameters

# gfs parameters
# getGFSParameters

check_cmd_params $*
shift $(($? - 1))

echo_local_debug "Debug: $debug"
echo_local_debug "Stepmode: $stepmode"
echo_local_debug "mount_opts: $mount_opts"
echo_local_debug "bootpart: $bootpart"
echo_local_debug "ip: $ipConfig"
echo_local_debug "*****************************"
x=`cat /proc/version`; 
KERNEL_VERSION=`expr "$x" : 'Linux version \([^ ]*\)'`
echo_local "0.2 Kernel-verion: ${KERNEL_VERSION}"
echo_local_debug "*****************************"

source $1
#*********** main

#####################
# $Log: exec_part_from_bash.sh,v $
# Revision 1.6  2007-12-07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.5  2006/05/03 12:46:35  marc
# added documentation
#
