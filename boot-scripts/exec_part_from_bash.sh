#!/bin/bash
#
# $Id: exec_part_from_bash.sh,v 1.3 2004-09-27 07:59:17 marc Exp $
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
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    bootpart=...          Which linuxrc.{bootpart} file should be loaded into 
#                  that script.
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output
#
# Marc Grimme: existence of /etc/gfs-lib.sh with all gfs-functions. 
#         Should be the framework for all other functionalities as well.

echo "Starting ATIX $0"
echo 'Version $Date: 2004-09-27 07:59:17 $'


. etc/sysconfig/comoonics

# initstuff is done in here
source /etc/boot-lib.sh

initBootProcess

# network parameters
getNetParameters

# gfs parameters
# getGFSParameters

# boot parameters
getBootParameters

opts=check_cmd_params $*
shift $(($opts - 1))

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

# $log$