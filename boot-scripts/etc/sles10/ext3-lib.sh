#
# $Id: ext3-lib.sh,v 1.1 2010-12-07 13:26:09 marc Exp $
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

#****f* boot-scripts/etc/ext3-lib.sh/ext3_getdefaults
#  NAME
#    ext3_getdefaults
#  SYNOPSIS
#    ext3_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function ext3_getdefaults {
	local param=$1
	case "$param" in
		lock_method|lockmethod)
		    echo ""
		    ;;
		mount_opts|mountopts)
		    echo "rw"
		    ;;
		root_source|rootsource)
		    echo "scsi"
		    ;;
                readonly)
                    echo 1
                    ;;
	    scsi_failover|scsifailover)
	        echo "driver"
	        ;;
	    *)
	        return 0
	        ;;
	esac
}
#********** ext3_getdefaults

##############
# $Log: ext3-lib.sh,v $
# Revision 1.1  2010-12-07 13:26:09  marc
# initial revision
#