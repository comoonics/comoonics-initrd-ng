#
# $Id: iscsi-lib.sh,v 1.3 2004-09-24 09:02:19 marc Exp $
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

parser="iscsi://([^:]+):([[:digit:]]+)/"

function getISCSIServerFromParam {
    echo $1 | awk '
{ 
   match($1, "'$parser'", iscsiparms);
   print iscsiparms[1];
}'
}

function getISCSIPortFromParam {
    echo $1 | awk '
{ 
   match($1, "'$parser'", iscsiparms);
   print iscsiparms[2];
}'
}

function createCiscoISCSICfgString {
    echo -n "DiscoveryAddress=$1" && ([ -n "$2" ] && echo ":$2") || echo
}

# $Log: iscsi-lib.sh,v $
# Revision 1.3  2004-09-24 09:02:19  marc
# another change for iscsi.cfg
#
# Revision 1.2  2004/09/24 08:56:14  marc
# bug in iscsi.cfg
#
# Revision 1.1  2004/09/23 16:30:01  marc
# initial revision
#