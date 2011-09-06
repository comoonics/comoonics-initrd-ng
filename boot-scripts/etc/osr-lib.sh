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

# Library to collect all clusterrelevant functions

#
# Generate nodeids and hwaddrs.
# osr_create_nodeids_attrs clustertype clusterconf querymap nodeids
osr_create_nodeids_attrs() {
	local clustertype=$1
	shift
	local cluster_conf=$1
	shift
	local querymap=$1
	shift
	local none="none"
	local nodeid=
	local nodeids=$*
	[ -z "$nodeids" ] && return 1
	repository_store_value nodeids "$nodeids"
	repository_store_value cluster_conf $cluster_conf
	repository_store_value osrquerymap $querymap
    for nodeid in $nodeids; do
      mac=$(${clustertype}_get hwids_by_nodeid $nodeid 2>/dev/null)
      [ -z "$mac" ] && mac="$none"
      repository_store_value "${nodeid}_hwaddr" "$mac"
    done
}  

osr_generate_nodevalues() {
	local nodeid=$1
	local osr_querymap="$2"
	local key2=""
	repository_store_value osrquerymap $osr_querymap
	for element in $(osr_get_cluster_elements); do # e.g. eth
		local keyname=$(osr_get_cluster_element_key $element)    # e.g. name
		error_local_debug "osr_generate_nodevalues nodeid: $nodeid element: $element, keyname: $keyname"
		if [ -n "$keyname" ]; then
			local keys=$(echo $(cc_get "${element}_$keyname" $nodeid))
			repository_store_value "${nodeid}_${element}_$keyname" "$keys" "" ""
			for key in $keys; do
				key2=$(osr_quote_or_remove $key)
				for attribute in $(osr_get_cluster_attributes $element); do  # e.g. ip
					# echo $element"_"$key2"_"$attribute="'"$(cc_get $element"_"$keyname"_"$attribute $nodeid $key)"'"
					repository_store_value "${nodeid}_${element}_${key2}_$attribute" "$(echo $(cc_get ${element}_${keyname}_$attribute $nodeid $key))" "" ""
				done
			done
		else
			for attribute in $(osr_get_cluster_attributes $element); do  # e.g. ip
#				echo $element"_"$attribute="'"$(cc_get $element"_"$attribute $nodeid $key)"'"
				repository_store_value "${nodeid}_${element}_$attribute" "$(echo $(cc_get ${element}_${attribute} $nodeid $key))" "" ""
			done
		fi
	done
}

#
# Returns a "string" as list of elements to be found in a cluster configuration
osr_get_cluster_elements() {
	echo "name clustername eth syslog rootvolume scsi rootsource chrootenv filesystem"
} 

#
# Returns a key for the element of the cluster configuration to be used. 
# This key needs to be unique for this node.  
osr_get_cluster_element_key() {
	local element=$1
	local key=""
	case "$element" in
		"eth") key="name" ;;
		"eth_*_properties") key="name" ;;
	    "filesystem") key="dest" ;;
		*) key=""
	esac
	echo $key
}

#
# Returns all attributes for a special element
osr_get_cluster_attributes() {
	case "$1" in
		"eth") echo "name mac ip gateway mask driver master slave type bridge properties" ;;
		"eth_*_properties") echo "name value" ;;
		"scsi") echo "name driver failover" ;;
		"syslog") echo "name level subsys type filter" ;;
		"rootvolume") echo "name fstype mountopts" ;;
	    "filesystem") echo "dest source fstype mountopts mounttimes mountwait" ;;
		"rootsource") echo "name" ;;
		"name") echo "name" ;;
		"clustername") echo "name" ;;
		"chrootenv") echo "mountpoint fstype device chrootdir" ;;
	esac
}

#
# Sets the <global> environment variables for network configurations
# variables: ip gw mask dev
osr_set_nodeconfig_net() {
	local nodeid=$1
	. $(repository_get_value confdir "/etc/conf.d")/osr-nodeidvalues-${nodeid}.conf
	for nic in $eth_name; do
		for attribute in $(osr_get_cluster_attributes eth); do
			case $attribute in
				"ip")  var="ip" ;;
				"gateway") var="gw" ;;
				"mask") var="mask" ;;
				"name") var="dev" ;;
				"hostname") var="hostname";;
				*) var="" ;;
			esac
			autoconf="none"
			eval $var=\$eth_${nic}_${attribute}
		done 
	done
	if [ "$ip" = "dhcp" ]; then
		echo $dev:$ip
	else
		echo $ip:$server:$gateway:$mask:$hostname:$dev:$autoconf
	fi
}

#
# Sets the <global> environment variables for root destination
# variables: fstype root options rflags [nfs] [server] [path]
osr_set_nodeconfig_root() {
	local nodeid=$1
	local temproot
	local temprootfstype

	. $(repository_get_value confdir "/etc/conf.d")/osr-nodeidvalues-${nodeid}.conf
	for attribute in $(osr_get_cluster_attributes rootvolume); do
		case $attribute in
			"name"|"root") temproot=$rootvolume_name ;;
			"fstype") fstype=$rootvolume_fstype ;;
			"options") 
				options=$rootvolume_options 
				rflags=$rootvolume_options
				;;
		esac
	done
	osr_parse_root_name "$temproot" "$fstype"
}

#
# Parses the rootname specified by the nodevalues and sets the environment variables.
# variables: fstype root [nfs] [server] [path]
osr_parse_root_name() {
	local temproot=$1
	local tempfstype=$2
	local index=1
	
	# first check if first char is /
	if [ $(expr substr $temproot 1 1) = "/" ]; then
		root=$temproot
		if [ -z "$tempfstype" ]; then
			fstype="ext3"
		else
			fstype="$tempfstype"
		fi
	elif [ $(echo "$temproot" | cut -f1 -d:) = "nfs" ] || [ $(echo "$temproot" | cut -f1 -d:) = "nfs4" ] || [ "$tempfstype" = "nfs" ] || [ "$tempfstype" = "nfs4" ]; then
		# Case NFS
		if [ -n "$tempfstype" ]; then
			nfs=$tempfstype
		else
			nfs=$(echo "$temproot" | cut -f$index -d:)
			index=$(( $index +1 ))
		fi
		fstype=$nfs
		server=$(echo "$temproot" | cut -f$index -d:)
		index=$(( $index +1 ))
		path=$(echo "$temproot" | cut -f$index -d:)
		index=$(( $index +1 ))
		options=$(echo "$temproot" | cut -f$index -d:)
		root="$fstype:$server:$path:$options"
		netroot=$root
	else
		return 1
	fi
}

#
# osr_resolve_element_alias(elements)
#  Will resolve an alias query.
#    ip => eth_name_ip
osr_resolve_element_alias() {
  local elements=$1
  case $elements in
    "ip") echo "eth_name_ip" ;;
    *)    echo "$elements" ;;
  esac
}

#
# osr_quote_or_remove keyname [symbolstoacceptasstring=[:alnum:]]
# removes unusable strings from key. Note that this could lead to not unique keys if they are having 
# special characters
osr_quote_or_remove() {
  local attr="$1"
  local acceptedsyms="[:alnum:]" 
  [ -n "$2" ] && acceptedsyms="$2"
  echo "$attr" | tr -c -d "$acceptedsyms"
}

#
# osr_get_node_attrs(attr subpath nodeid nodename name)
osr_get_node_attrs() {
  local attr=$(osr_quote_or_remove $1)
  local elements=$2
  local nodeid=$3
  local nodename=$4
  local name=$(osr_quote_or_remove $5)
  local element=""
  local value=""
  local values=""
  local delim=" "
  local keyname=""
  local key=""
  
  test -n "$attr"     || return 3 
    
  elements=$(osr_resolve_element_alias $elements)
  
  # if either no nodename and nodeid is given use all available nodeids
  if [ -z "$nodeid" ] && [ -z "$nodename" ]; then
     for nodeid in $(osr_get_nodeids); do
       osr_get_node_attrs "$attr" "$elements" "$nodeid" "$nodename" "$name"
     done
     return
  fi
  
  # get attributes for all available elements
  test -z "$elements" && elements=$(osr_get_cluster_elements)
  for element in $elements; do
    keyname=$(osr_get_cluster_element_key $element)    # e.g. name
  	if [ -n "$name" ]; then
      value=$(repository_get_value "${nodeid}_${element}_${name}_${attr}")
      test -n "$value" && values="${values}${delim}${value}"
    else
      value=$(repository_get_value ${nodeid}_${element}_${attr})
      if [ -z "$value" ] && [ -n "$keyname" ] && [ "$keyname" != "$attr" ]; then
      	for key in $(osr_get_node_attrs "$keyname" "$element" "$nodeid" "$nodename" "" "$nodesconf" "$nodeconf"); do 
      	  key=$(osr_quote_or_remove "$key")
      	  value=$(repository_get_value ${nodeid}_${element}_${key}_${attr})
      	  test -n "$value" && values="${values}${delim}${value}"
        done
      else
        test -n "$value" && values="${values}${delim}${value}"
      fi
    fi
  done
  test -n "$values" && echo $values
  test -n "$values"
  return $?
}

#
# Clusterlib derived functions

#
# convert to other format
#  NOT supported and not sensible.
osr_convert() {
  return 0
}

#
# osr_getdefaults
# returns the defaults for an osr cluster
# Cluster defaults for OSR based clusters are
#  rootfs: nfs
#  scsi_failover: mapper
#  ip: cluster
osr_getdefaults() {
	local param=$1
	
	case "$param" in
		rootfs|root_fs)
            echo "nfs"
		    ;;
	    scsi_failover|scsifailover)
	        echo "mapper"
	        ;;
	    ip)
	        echo "cluster"
	        ;;
	    *)
	        return 0
	        ;;
	esac
}

#
# osr_get_nodeids
#  returns all nodeids
osr_get_nodeids() {
  local nodeid=""
  local mac=""
  local delim=" "
  local nodeids=""
  
  for nodeid in $(repository_get_value nodeids); do
  	nodeids=${nodeids}${delim}$nodeid
  done
  [ -n "$nodeids" ] && echo $nodeids
  [ -n "$nodeids" ]
  return $?
}

#
# osr_get query nodeid attrs
# Examples:
#   osr_get eth_name_name nodeid attr  
osr_get() {
  local query=$(osr_resolve_element_alias $1)
  local nodeid=${2:-1}
  local key=$3
  local element=$(echo $query | cut -f1 -d_)
  local keyname=$(osr_get_cluster_element_key $element)
  
  if [ -n "$keyname" ] && [ -n "$key" ]; then
    query=$(echo $query | cut -f3- -d_)
  else
    query=$(echo $query | cut -f2- -d_)
  fi
  osr_get_node_attrs "$query" "$element" $nodeid "" "$key"
}

#
# osr_get_macs
#  returns all macs
osr_get_macs() {
  local nodeid=""
  local mac=""
  local _mac=""
  local delim=" "
  local macs=""
  local none="none"
  
  for nodeid in $(repository_get_value nodeids); do
  	mac=$(repository_get_value ${nodeid}_hwaddr)
  	if [ -z "$mac" ]; then
  	  continue
  	fi
  	for _mac in $mac; do
  	  if [ $_mac == $none ]; then
  	    continue
  	  fi
      macs=${macs}${delim}$_mac
  	done
  done
  [ -n "$macs" ] && echo $macs
  [ -n "$macs" ]
  return $?
}

#
# osr_get_nodeid(hwaddr)
#   hwaddr=macaddress
#   returns the nodeid of this macaddress
osr_get_nodeid() {
  local _mac=$1
  local mac=""
  local macs=""
  
  local nodeid=""
  local delim=" "
  
  for nodeid in $(repository_get_value nodeids); do
    macs=$(repository_get_value ${nodeid}_hwaddr)
  	if [ -z "$macs" ]; then
  	  continue
  	fi
  	for mac in $macs; do
  	  if [ $_mac == $mac ]; then
  	    echo "$nodeid"
  	    return 0
  	  fi
  	done
  done
  return 1
}

osr_get_drivers() {
   echo ""
}
osr_get_userspace_procs() {
  echo
}

osr_get_clustername() {
   osr_get_node_attrs "name" "clustername" "$@"
}
osr_get_nic_names() {
   osr_get_node_attrs "name" "eth" "$@"
}
osr_get_nic_drivers() {
   osr_get_node_attrs "driver" "eth" "$@"
}
osr_get_all_drivers() {
   osr_get_node_attrs "driver" "" "$@"
}
osr_get_nodename_by_id() {
  osr_get_node_attrs "name" "name" "$@"
}
osr_get_rootvolume() {
  osr_get_node_attrs "name" "rootvolume" "$@"
}
osr_get_rootsource() {
  osr_get_node_attrs "name" "rootsource" "$@"
}
osr_get_rootfs() {
  osr_get_node_attrs "fstype" "rootvolume" "$@"
}
osr_get_mountopts() {
  osr_get_node_attrs "mountopts" "rootvolume" "$@"
}
osr_get_chroot_mountpoint() {
  osr_get_node_attrs "mountpoint" "chrootenv" "$@"
}
osr_get_chroot_fstype() {
  osr_get_node_attrs "fstype" "chrootenv" "$@"
}
osr_get_chroot_device() {
  osr_get_node_attrs "device" "chrootenv" "$@"
}
osr_get_chroot_mountopts() {
  osr_get_node_attrs "mountopts" "chrootenv" "$@"
}
osr_get_syslogserver() {
  osr_get_node_attrs "name" "syslog" "$@"
}
osr_get_syslogfilter() {
  osr_get_node_attrs "filter" "syslog" "$@"
}
osr_get_scsifailover() {
  osr_get_node_attrs "failover" "scsi" "$@"
}
osr_get_netdevs() {
  osr_get_node_attrs "name" "eth" "$@"
}

#
# osr_init start|stop|restart
osr_init() {
  return 0
}
#****f* osr-lib.sh/osr_validate
#  NAME
#    osr_validate
#  SYNOPSIS
#    function osr_validate(cluster_conf)
#  DESCRIPTION
#    validates the cluster configuration. 
#  SOURCE
osr_validate() {
	true
}
#*********** osr_validate

#
# osr_auto_hosts
osr_auto_hosts() {
  local nodeid=""
  local netdev=""
  local nodename=""
  local ip=""
  
  for nodeid in $(osr_get_nodeids); do
    nodename=$(osr_get name "$nodeid")
    for netdev in $(osr_get eth_name "$nodeid"); do
      if [ -n "$ip" ]; then
      	continue
      else
        ip=$(osr_get eth_name_ip "$nodeid" $netdev)
        [ -n "$ip" ] && [ -n "$nodename" ] && echo "$ip $nodename"
      fi
    done  
  done 
}
