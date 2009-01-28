#
# $Id: repository-lib.sh,v 1.3 2009-01-28 12:55:50 marc Exp $
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

[ -z "$REPOSITORY_PREFIX" ] && REPOSITORY_PREFIX=__repository__
[ -z "$REPOSITORY_PATH" ] && REPOSITORY_PATH="/tmp"
[ -z "$REPOSITORY_DEFAULT" ] && REPOSITORY_DEFAULT="comoonics_bootimage"
[ -z "$REPOSITORY_FS" ] && REPOSITORY_FS="__"

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
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	if [ -e ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository} ]; then
		. ${REPOSITORY_PATH}/$REPOSITORY_PREFIX${repository}
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
#    function repository_store_value(key, value, repository_name)
#  DESCRIPTION
#    stores the key/value pair into the repository with the name repository_name. 
#    If repository name is not give REPOSITORY_DEFAULT is used.
#  IDEAS
#  SOURCE
#
function repository_store_value() {
	local value="__set__"
	if [ $# -gt 1 ]; then
		value="$2"
	fi
	local repository="$3"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}$(repository_normalize_value ${1})=\"$value\""
	echo "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}$(repository_normalize_value ${1})=\"$value\"" >> ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}
}
#******* repository_store_value

#****f* repository-lib.sh/repository_append_value
#  NAME
#    repository_append_value
#  SYNOPSIS
#    function repository_append_value(key, value, repository_name)
#  DESCRIPTION
#    appends the key/value pair into the repository with the name repository_name. 
#    If repository name is not give REPOSITORY_DEFAULT is used.
#  IDEAS
#  SOURCE
#
function repository_append_value() {
	local repository="$3"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local value=$(repository_get_value $1)
	eval "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}$(repository_normalize_value ${1})=${value}\"$2\""
	echo "${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}$(repository_normalize_value ${1})=${value}\"$2\"" >> ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}
}
#******* repository_append_value

#****f* repository-lib.sh/repository_list_keys
#  NAME
#    repository_list_keys
#  SYNOPSIS
#    function repository_list_keys(repository_name)
#  DESCRIPTION
#    return a list of all variablenames found in the given repository
#  IDEAS
#  SOURCE
#
function repository_list_keys() {
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local values=""
	local index=0
	repository_load $repository
	for key in $(typeset | grep "^${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}[^[:space:]]*=" | cut -d"=" -f1); do
		values[$index]=${key/${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}}
		index=$(($index + 1)) 
   	done		
   	echo ${values[@]}
}
#******* repository_list_keys

#****f* repository-lib.sh/repository_list_values
#  NAME
#    repository_list_values
#  SYNOPSIS
#    function repository_list_values(repository_name)
#  DESCRIPTION
#    return a list of all variablevalues found in the given repository
#  IDEAS
#  SOURCE
#
function repository_list_values() {
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local values=""
	local index=0
	repository_load $repository
	for value in $(typeset | grep "^${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}[^[:space]]*=" | cut -d"=" -f2); do
		values[$index]=$value
		index=$(($index + 1)) 
   	done		
   	echo ${values[@]}
}
#******* repository_list_values

#****f* repository-lib.sh/repository_list_items
#  NAME
#    repository_list_items
#  SYNOPSIS
#    function repository_list_items(ofs, ls, repository_name)
#  DESCRIPTION
#    return a list of all variablevalues found in the given repository
#  IDEAS
#  SOURCE
#
function repository_list_items() {
	local repository="$3"
	local OFS=" "
	local LS="\n"
	[ -n "$1" ] && OFS="$1"
	[ -n "$2" ] && LS="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	local values=""
	repository_load $repository
	for key in $(repository_list_keys $repository); do
		if repository_has_key $key $repository; then
	      values=${values}${LS}${key}${OFS}$(repository_get_value $key $repository)
		fi
  	done		
 	echo -e $values
}
#******* repository_list_items

#****f* repository-lib.sh/repository_get_value
#  NAME
#    repository_get_value
#  SYNOPSIS
#    function repository_get_value(key, repository_name)
#  DESCRIPTION
#    return the value from the repository with the name repository_name
#  IDEAS
#  SOURCE
#
function repository_get_value() {
	local repository="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	repository_load $repository
	eval "val=\$${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}$(repository_normalize_value ${1})"
	if [ -n "$val" ]; then
		echo $val
		return 0
	fi
	return 1
}
#******* repository_get_value

#****f* repository-lib.sh/repository_has_key
#  NAME
#    repository_has_key
#  SYNOPSIS
#    function repository_has_key(key, repository_name)
#  DESCRIPTION
#    return if the key exists in repository
#  IDEAS
#  SOURCE
#
function repository_has_key() { 
	local repository="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	repository_load $repository
	val=$(repository_get_value $1 $repository)
	return $?
}
#******* repository_has_key

#****f* repository-lib.sh/repository_del_value
#  NAME
#    repository_del_value
#  SYNOPSIS
#    function repository_del_value(key, repository_name)
#  DESCRIPTION
#    remove the given key from the repository.
#  IDEAS
#  SOURCE
#
function repository_del_value() { 
	local repository="$2"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
	val=$(repository_get_value $1 $repository)
	if [ $? -eq 0 ]; then
		eval "unset ${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}$(repository_normalize_value ${1})"
		echo "unset ${REPOSITORY_PREFIX}${repository}${REPOSITORY_FS}$(repository_normalize_value ${1})" >> ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}
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
	local repository="$1"
	[ -z "$repository" ] && repository=${REPOSITORY_DEFAULT}
  	for key in $(typeset | grep "^${REPOSITORY_PREFIX}${repository}[^[:space:]]*=" | cut -d"=" -f1); do
		eval "unset ${key}"
   	done
    if [ -e ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository} ]; then
    	rm -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}
    fi
}
#******** repository_clear

#############
# $Log: repository-lib.sh,v $
# Revision 1.3  2009-01-28 12:55:50  marc
# - some bugfixes
# - cleaned the code
# - added functions to make better use of it (clean, del, append)
#