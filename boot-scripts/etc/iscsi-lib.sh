#
# $Id: iscsi-lib.sh,v 1.14 2009-08-11 09:57:48 marc Exp $
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
# Library for the iscsi-interface

#****h* comoonics-bootimage/iscsi-lib.sh
#  NAME
#    iscsi-lib.sh
#    $id$
#  DESCRIPTION
#*******

iscsiparser1="iscsi://([^:/]+)"
iscsiparser2="iscsi://([^:]+):([[:digit:]]+)/"
iscsiparser3="^iscsi"
iscsiparser4="iscsi://([^:]+):([[:digit:]]+)/(.+)"


#****f* iscsi-lib.sh/getISCSIInitiatorFromParam
#  NAME
#    getISCSIInitiatorFromParam
#  SYNOPSIS
#    function getISCSIInitiatorServerFromParam {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getISCSIInitiatorFromParam {
    echo $1 | awk '
{
   match($1, "'$iscsiparser4'", iscsiparms);
   print iscsiparms[3];
}'
}

#****f* iscsi-lib.sh/getISCSIServerFromParam
#  NAME
#    getISCSIServerFromParam
#  SYNOPSIS
#    function getISCSIServerFromParam {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getISCSIServerFromParam {
    echo $1 | awk '
{
   match($1, "'$iscsiparser1'", iscsiparms);
   print iscsiparms[1];
}'
}

#************ getISCSIServerFromParam

#****f* iscsi-lib.sh/getISCSIPortFromParam
#  NAME
#    getISCSIPortFromParam
#  SYNOPSIS
#    function getISCSIPortFromParam {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getISCSIPortFromParam {
    echo $1 | awk '
{
   match($1, "'$iscsiparser2'", iscsiparms);
   print iscsiparms[2];
}'
}
#************ getISCSIPortFromParam

#****f* iscsi-lib.sh/createCiscoISCSICfgString
#  NAME
#    createCiscoISCSICfgString
#  SYNOPSIS
#    function createCiscoISCSICfgString {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function createCiscoISCSICfgString {
    echo -n "DiscoveryAddress=$1" && ([ -n "$2" ] && echo ":$2") || echo
}
#************ createCiscoISCSICfgString

#****f* iscsi-lib.sh/iscsi_get_drivers
#  NAME
#    iscsi_get_drivers
#  SYNOPSIS
#    function iscsi_get_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function iscsi_get_drivers {
	echo "iscsi_tcp scsi_transport_iscsi libiscsi"
}
#************ iscsi_get_drivers

#****f* iscsi-lib.sh/loadISCSI
#  NAME
#    loadISCSI
#  SYNOPSIS
#    function loadISCSI
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function loadISCSI {
	local iscsimodules=$(iscsi_get_drivers)
	echo_local -n "Loading iscsimodules"
	for module in $iscsimodules; do
		exec_local modprobe $module
	done
	return_code
}
#************ loadISCSI

#****f* iscsi-lib.sh/startISCSI
#  NAME
#    startISCSI
#  SYNOPSIS
#    function startISCSI
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function startISCSI {
	local rootsource=$1
	local nodename=$2
	local iscsiserver=$(getISCSIServerFromParam $rootsource)
	local iscsimodules="iscsi_tcp"
	local iscsiinitiatorname=$(getISCSIInitiatorFromParam $rootsource)
	echo_local -n "Starting iscsid"
	
	if [ -n "$iscsiinitiatorname" ]; then
		echo "InitiatorName=$iscsiinitiatorname" >/etc/iscsi/initiatorname.iscsi
		echo_local -n "Initiatorname is $iscsiinitiatorname"
	fi
    modprobe -q iscsi_tcp
    modprobe -q ib_iser
    exec_local iscsid
	return_code $?
	if [ -n "$iscsiserver" ]; then
	   echo_local -n "Importing from node $iscsiserver"
	   rm -rf /var/lib/iscsi
	   iscsiadm --mode discovery --type sendtargets --portal $iscsiserver &&
       iscsiadm -m node --loginall=automatic
	else
	   echo_local -n "Importing old nodes"
       iscsiadm -m node --loginall=automatic
	fi
}
#************ startISCSI

#****f* iscsi-lib.sh/isISCSIRootsource
#  NAME
#    isISCSIRootsource
#  SYNOPSIS
#    function isISCSIRootsource
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function isISCSIRootsource {
	local rootsource=$1
	if [ -z "$rootsource" ]; then
		return 1
	else
      echo $1 | awk '
/'$iscsiparser3'/ {
	exit 0
  }
  {
  	exit 1
  }'
      return $?
    fi
    return 1
}
#************ isISCSIRootsource

# $Log: iscsi-lib.sh,v $
# Revision 1.14  2009-08-11 09:57:48  marc
# Here is a patch that uses an extended rootsource syntax for setting an
# node-specific Initiatorname.
# The syntax used is: <rootsource
# name="iscsi://<target-ip>:<port>/<Initiatorname>"/>
# (Michael Peus)
#
# Revision 1.13  2009/04/14 14:54:16  marc
# - added get_drivers functions
#
# Revision 1.12  2008/06/10 09:58:43  marc
# - fixed bug with parser
#
# Revision 1.11  2008/01/24 13:32:13  marc
# - rewrote iscsi configuration to be more generic
#
# Revision 1.10  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.9  2007/10/16 08:02:21  marc
# - preview version
#
# Revision 1.8  2006/05/03 12:45:13  marc
# added documentation
#
# Revision 1.7  2004/09/29 14:32:16  marc
# vacation checkin, stable version
#
# Revision 1.6  2004/09/24 14:40:47  marc
# parser1=>parser2
#
# Revision 1.5  2004/09/24 14:33:27  marc
# bug in parser1
#
# Revision 1.4  2004/09/24 14:25:04  marc
# added second parser to support urls like iscsi://hostname//
#
# Revision 1.3  2004/09/24 09:02:19  marc
# another change for iscsi.cfg
#
# Revision 1.2  2004/09/24 08:56:14  marc
# bug in iscsi.cfg
#
# Revision 1.1  2004/09/23 16:30:01  marc
# initial revision
#
