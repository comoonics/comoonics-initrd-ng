#
# $Id: linuxrc.part.iscsi.sh,v 1.3 2004-09-24 09:05:31 marc Exp $
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

source etc/iscsi-lib.sh
source etc/boot-lib.sh

stage=0
part="ISCSI"
[ -z "$iscsi" ] && return 0
iscsi_server=$(getISCSIServerFromParam $iscsi)
iscsi_port=$(getISCSIPortFromParam $iscsi)
iscsi_cfgfile="/etc/iscsi.cfg"
echo_local_debug "$stage $part: ISCSI-Params: "
echo_local_debug "$stage ${part}.1 ISCSI-Server: $iscsi_server"
echo_local_debug "$stage ${part}.1 ISCSI-Port: $iscsi_port"

echo_local -n "$part $stage: Creating iscsi-cfgfile"
exec_local $(createCiscoISCSICfgString $iscsi_server $iscsi_port>> $iscsi_cfgfile)

echo_local_debug  "$part $stage: ISCSI CFG-File: $iscsi_cfgfile"
exec_local_debug  cat $iscsi_cfgfile

echo_local -n "$part $stage: Starting iscsi-client..."
exec_local /etc/init.d/iscsi start

# $Log: linuxrc.part.iscsi.sh,v $
# Revision 1.3  2004-09-24 09:05:31  marc
# appending to iscsi-cfg file
#
# Revision 1.2  2004/09/24 08:56:31  marc
# bug in creating iscsi-cfg file.
#
# Revision 1.1  2004/09/23 16:29:45  marc
# initial revision
#