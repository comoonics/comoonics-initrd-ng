#
# $Id: iscsi-lib.sh,v 1.10 2007-12-07 16:39:59 reiner Exp $
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

parser1="iscsi://([^:]+)"
parser2="iscsi://([^:]+):([[:digit:]]+)/"
parser3="^iscsi"

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
   match($1, "'$parser1'", iscsiparms);
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
   match($1, "'$parser2'", iscsiparms);
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
	local iscsimodules="iscsi_tcp"
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
	local iscsimodules="iscsi_tcp"
	echo_local -n "Starting iscsid"
	service iscsid start >/dev/null 2>&1
	return_code $?
	echo_local -n "Starting iscsi"
	service iscsi start >/dev/null 2>&1
	return_code $?
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
/'$parser3'/ {
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
# Revision 1.10  2007-12-07 16:39:59  reiner
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
