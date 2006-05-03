#
# $Id: linuxrc.part.iscsi.sh,v 1.9 2006-05-03 12:45:54 marc Exp $
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
# iscsi=... The url to the iscsi-server targets: iscsi://server[:port]/

#
# Includes
# %%include /etc/iscsi-lib.sh

#****h* comoonics-bootimage/linuxrc.part.iscsi.sh
#  NAME
#    linuxrc.part.iscsi.sh
#    $Id: linuxrc.part.iscsi.sh,v 1.9 2006-05-03 12:45:54 marc Exp $
#  DESCRIPTION
#    The scripts called from linuxrc.generic.sh if iscsi is used.
#*******

#****f* linuxrc.part.iscsi.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#

source etc/iscsi-lib.sh
source etc/boot-lib.sh

stage=0
part="ISCSI"
[ -z "$iscsi" ] && return 0
iscsi_server=$(getISCSIServerFromParam $iscsi)
iscsi_port=$(getISCSIPortFromParam $iscsi)
iscsi_cfgfile="/etc/iscsi.conf"
echo_local_debug "$stage $part: ISCSI-Params: "
echo_local_debug "$stage ${part}.1 ISCSI-Server: $iscsi_server"
echo_local_debug "$stage ${part}.1 ISCSI-Port: $iscsi_port"

if [ -n "$iscsi_server" ]; then
  echo_local -n "$part $stage: Creating iscsi-cfgfile"
  exec_local $(createCiscoISCSICfgString $iscsi_server $iscsi_port>> $iscsi_cfgfile)
  step

  echo_local_debug  "$part $stage: ISCSI CFG-File: $iscsi_cfgfile"
  exec_local_debug  cat $iscsi_cfgfile
  step

  echo_local -n "$part $stage: Starting iscsi-client..."
  /etc/init.d/iscsi start
  ([ $? -eq 0 ] && echo "(OK)") || echo "(FAILED)"
  sleep 5
  step
fi
#********** main

# $Log: linuxrc.part.iscsi.sh,v $
# Revision 1.9  2006-05-03 12:45:54  marc
# added documentation
#
# Revision 1.8  2004/09/24 15:37:11  marc
# added sleep
#
# Revision 1.7  2004/09/24 15:27:15  marc
# change way to execute iscsi
#
# Revision 1.6  2004/09/24 14:33:40  marc
# checking for empty or wrong iscsi-server
#
# Revision 1.5  2004/09/24 14:15:34  marc
# added steps
#
# Revision 1.4  2004/09/24 09:13:59  marc
# change iscsi.cfg to iscsi.conf
#
# Revision 1.3  2004/09/24 09:05:31  marc
# appending to iscsi-cfg file
#
# Revision 1.2  2004/09/24 08:56:31  marc
# bug in creating iscsi-cfg file.
#
# Revision 1.1  2004/09/23 16:29:45  marc
# initial revision
#
