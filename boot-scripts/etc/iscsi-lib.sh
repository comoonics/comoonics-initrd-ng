#
# $Id: iscsi-lib.sh,v 1.8 2006-05-03 12:45:13 marc Exp $
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
# Library for the iscsi-interface

#****h* comoonics-bootimage/iscsi-lib.sh
#  NAME
#    iscsi-lib.sh
#    $id$
#  DESCRIPTION
#*******

parser1="iscsi://([^:]+)"
parser2="iscsi://([^:]+):([[:digit:]]+)/"

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

# $Log: iscsi-lib.sh,v $
# Revision 1.8  2006-05-03 12:45:13  marc
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
