#
# $Id: repository-lib.sh,v 1.2 2008-10-28 12:53:50 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH, 2008 ATIX AG.
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
#****h* comoonics-bootimage/repository-lib.sh
#  NAME
#    repository-lib.sh
#    $id$
#  DESCRIPTION
#    Library for std operations
#*******

REPOSITORY_PREFIX=__repository__

#****f* repository-lib.sh/repository_load
#  NAME
#    repository_load
#  SYNOPSIS
#    function repository_load(name)
#  DESCRIPTION
#    loads the repository
#  IDEAS
#  SOURCE
#
function repository_load() {
	if [ -e /tmp/$REPOSITORY_PREFIX$1 ]; then
		. /tmp/$REPOSITORY_PREFIX$1
	fi
}
#******* repository_load


#****f* repository-lib.sh/repository_normalize_value
#  NAME
#    repository_normalize_value
#  SYNOPSIS
#    function repository_normalize_value(value)
#  DESCRIPTION
#    normalizes a value
#  IDEAS
#  SOURCE
#
function repository_normalize_value() {
	echo $1 | tr '-' '_'
}
#******* repository_store_value

#****f* repository-lib.sh/repository_store_value
#  NAME
#    repository_store_value
#  SYNOPSIS
#    function repository_store_value(repository_name, key, value)
#  DESCRIPTION
#    stores the key/value pair into the repository with the name repository_name
#  IDEAS
#  SOURCE
#
function repository_store_value() {
	eval "${REPOSITORY_PREFIX}${1}__$(repository_normalize_value ${2})=$3"
	echo "${REPOSITORY_PREFIX}${1}__$(repository_normalize_value ${2})=$3" >> /tmp/$REPOSITORY_PREFIX$1
}
#******* repository_store_value

#****f* repository-lib.sh/repository_get_value
#  NAME
#    repository_get_value
#  SYNOPSIS
#    function repository_get_value(repository_name, key, value)
#  DESCRIPTION
#    return the value from the repository with the name repository_name
#  IDEAS
#  SOURCE
#
function repository_get_value() {
	repository_load $1
	eval "val=\$${REPOSITORY_PREFIX}${1}__$(repository_normalize_value ${2})"
	if [ -n "$val" ]; then
		echo $val
		return 0
	fi
	return 1
}
#******* repository_get_value

#****f* repository-lib.sh/repository_has_key
#  NAME
#    repository_get_value
#  SYNOPSIS
#    function repository_has_key(repository_name, key)
#  DESCRIPTION
#    return if the key exists in repository
#  IDEAS
#  SOURCE
#
function repository_has_key() { 
	repository_load $1
	val=$(repository_get_value $1 $2)
	return $?
}
#******* repository_has_key

#****f* repository-lib.sh/repository_del_value
#  NAME
#    repository_get_value
#  SYNOPSIS
#    function repository_has_key(repository_name, key)
#  DESCRIPTION
#    return if the key exists in repository
#  IDEAS
#  SOURCE
#
function repository_del_value() { 
	val=$(repository_get_value $1 $2)
	if [ $? -eq 0 ]; then
		eval "unset ${REPOSITORY_PREFIX}${1}__$(repository_normalize_value ${2})"
	fi
}
#******* repository_del_value

#*****f* repository-lib.sh/repository_clear
#  NAME
#    repository_clear
#  SYNOPSIS
#    function repository_clear(repository_name)
#  DESCRIPTION
#    clears the given repository from disk
#  IDEAS
#  SOURCE
#
function repository_clear {
        if [ -e /tmp/$REPOSITORY_PREFIX$1 ]; then
                rm -f /tmp/$REPOSITORY_PREFIX$1
        fi
}
#******** repository_clear
