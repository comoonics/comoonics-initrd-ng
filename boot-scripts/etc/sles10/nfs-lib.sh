#
# $Id: nfs-lib.sh,v 1.1 2010-08-11 09:40:51 marc Exp $
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

#****h* comoonics-bootimage/nfs-lib.sh
#  NAME
#    nfs-lib.sh
#    $id$
#  DESCRIPTION
#    Local nfs dependencies for sles10
#*******

#****f* clusterfs-lib.sh/nfs_get_drivers
#  NAME
#    nfs_get_drivers
#  SYNOPSIS
#    function nfs_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function nfs_get_drivers {
	echo "sunrpc nfs lockd nfs_acl"
}
#*********** nfs_get_drivers

#****f* nfs-lib.sh/nfs_services_start
#  NAME
#    nfs_services_start
#  SYNOPSIS
#    function nfs_services_start
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function nfs_services_start {
  return 0
}
#************ nfs_services_start

#****f* nfs-lib.sh/nfs_services_stop
#  NAME
#    nfs_services_stop
#  SYNOPSIS
#    function nfs_services_stop
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function nfs_services_stop {
  return 0
}
#************ nfs_services_stop

# $Log: nfs-lib.sh,v $
# Revision 1.1  2010-08-11 09:40:51  marc
# - removed the portmap dep
#
