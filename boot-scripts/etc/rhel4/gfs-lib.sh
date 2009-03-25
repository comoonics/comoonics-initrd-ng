#
# $Id: gfs-lib.sh,v 1.2 2009-03-25 13:52:52 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2007 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
#****h* boot-scripts/etc/rhel5/gfs-lib.sh
#  NAME
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for gfs support functions for Red Hat
#    Enterprise Linux 4.
#*******

#****f* clusterfs-lib.sh/gfs_get_drivers
#  NAME
#    gfs_get_drivers
#  SYNOPSIS
#    function gfs_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function gfs_get_drivers {
	echo "cman dlm lock_dlm gfs configfs lock_gulm lock_nolock"
}
#*********** gfs_get_drivers

###############
# $Log: gfs-lib.sh,v $
# Revision 1.2  2009-03-25 13:52:52  marc
# initial revision
#
