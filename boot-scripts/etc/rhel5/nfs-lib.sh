#
# $Id: nfs-lib.sh,v 1.2 2009-08-11 09:53:27 marc Exp $
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
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#*******


#****f* nfs-lib.sh/nfs4_services_start
#  NAME
#    nfs4_services_start
#  SYNOPSIS
#    function nfs4_services_start
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function nfs4_services_start {
  local services="rpcpipefs portmap rpc_idmapd"
  for service in $services; do
    nfs4_start_$service $*
  done
  return 0
}
#************ nfs_services_start

#****f* nfs-lib.sh/nfs4_services_stop
#  NAME
#    nfs_services_stop
#  SYNOPSIS
#    function nfs_services_stop
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function nfs4_services_stop {
  local services="rpc_idmapd rpcbind rpcpipefs"
  for service in $services; do
    nfs4_stop_$service $*
  done
  return 0
}
#************ nfs_services_stop

#****f* nfs-lib.sh/nfs4_get_userspace_procs
#  NAME
#    nfs4_get_userspace_procs
#  SYNOPSIS
#    function nfs4_get_userspace_procs(nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function nfs4_get_userspace_procs {
  local clutype=$1
  local rootfs=$2

  echo -e "portmap \n\
rpc.idmapd"
}
#******** nfs4_get_userspace_procs
