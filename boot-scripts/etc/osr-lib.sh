# Library to collect all clusterrelevant functions

osr_generate_nodevalues() {
	nodeid=$1
	osr_querymap="$2"
	repository_store_value osrquerymap $osr_querymap
	for element in $(osr_get_cluster_elements); do # e.g. eth
		keyname=$(osr_get_cluster_element_key $element)    # e.g. name
		error_local_debug "osr_generate_nodevalues nodeid: $nodeid element: $element, keyname: $keyname"
		if [ -n "$keyname" ]; then
			keys=$(cc_get $element"_"$keyname $nodeid)
			echo $element"_"$keyname"='"$keys"'"
			for key in $keys; do
				for attribute in $(osr_get_cluster_attributes $element); do  # e.g. ip
					echo $element"_"$key"_"$attribute="'"$(cc_get $element"_"$keyname"_"$attribute $nodeid $key)"'"
				done
			done
		else
			for attribute in $(osr_get_cluster_attributes $element); do  # e.g. ip
				echo $element"_"$attribute="'"$(cc_get $element"_"$attribute $nodeid $key)"'"
			done
		fi
	done
}

#
# Returns a "string" as list of elements to be found in a cluster configuration
osr_get_cluster_elements() {
	echo "name clustername eth syslog rootvolume fenceacksv scsi rootsource chrootenv"
} 

#
# Returns a key for the element of the cluster configuration to be used. 
# This key needs to be unique for this node.  
osr_get_cluster_element_key() {
	element=$1
	case "$element" in
		"eth") key="name" ;;
		"eth_*_properties") key="name" ;;
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
		"rootsource") echo "name" ;;
		"fenceacksv") echo "name" ;;
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
	. /etc/conf.d/osr-nodeidvalues-${nodeid}.conf
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

	. /etc/conf.d/osr-nodeidvalues-${nodeid}.conf
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
# Returns the nodeids file
osr_nodeids_file() {
	echo "/tmp/osr-nodeids"
}

# 
# Return the nodeid file
osr_nodeid_file() {
	echo "/etc/conf.d/osr-nodeidvalues-$1.conf"
}

#
# Generate nodeids file
# osr_create_nodeids_file clustertype clusterconf querymap nodeids
osr_create_nodeids_file() {
	local clustertype=$1
	shift
	local cluster_conf=$1
	shift
	local querymap=$1
	shift
	local none="none"
	
    for nodeid in $*; do
      mac=$(${clustertype}_get $cluster_conf $querymap macs $nodeid 2>/dev/null)
      [ -z "$mac" ] && mac="$none"
      echo "$nodeid $mac"
    done
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
# Clusterlib derived functions

#
# osr_get_clustername nodeid [nodes_conf] [node_conf]
osr_get_clustername() {
   local nodeconf=$3
   local nodeid=$1
   [ -z "$nodeconf" ] && nodeconf=$(osr_nodeid_file $nodeid)
   osr_get_node_attrs "name" "clustername" "$nodeid" "" "" "$2" "$nodeconf"
}

#
# convert to other format
#  NOT supported and not sensible.
osr_convert() {
  return 0
}

#
# osr_get_nicnames(nodeid, nodename, nicname, [nodesconf], [nodeconf])
osr_get_nic_names() {
   osr_get_node_attrs "name" "eth" "$1" "$2" "$3" "$4" "$5"
}

osr_get_nic_drivers() {
   osr_get_node_attrs "driver" "eth" "$1" "$2" "$3" "$4" "$5"
}

osr_get_all_drivers() {
   osr_get_node_attrs "driver" "" "$1" "$2" "$3" "$4" "$5"
}

#
# osr_get_node_attrs(attr subpath nodeid nodename name [nodesconf] [nodeconf])
osr_get_node_attrs() {
  local attr=$1
  local elements=$2
  local nodeid=$3
  local nodename=$4
  local name=$5
  local nodesconf=$6
  local nodeconf=$7
  local element=""
  local value=""
  local values=""
  local delim=" "
  local keyname=""
  local key=""
  
  [ -z "$nodeconf" ] && nodeconf=$(repository_get_value nodeconf $(osr_nodeid_file $nodeid))
  
  test -f "$nodeconf" || return 2
  test -n "$attr"     || return 3 
  
  . $nodeconf
  
  elements=$(osr_resolve_element_alias $elements)
  
  # if either no nodename and nodeid is given use all available nodeids
  if [ -z "$nodeid" ] && [ -z "$nodename" ]; then
     for nodeid in $(osr_get_nodeids); do
       osr_get_node_attrs "$attr" "$elements" "$nodeid" "$nodename" "$name" "$nodesconf" "$nodeconf"
     done
     return
  fi
  
  # get attributes for all available elements
  test -z "$elements" && elements=$(osr_get_cluster_elements)
  for element in $elements; do
    keyname=$(osr_get_cluster_element_key $element)    # e.g. name
  	if [ -n "$name" ]; then
      eval value=\$${element}_${name}_${attr}
      test -n "$value" && values="${values}${delim}${value}"
    else
      eval value=\$${element}_${attr}
      if [ -z "$value" ] && [ -n "$keyname" ]; then
      	for key in $(osr_get_node_attrs "$keyname" "$element" "$nodeid" "$nodename" "" "$nodesconf" "$nodeconf"); do 
      	  eval value=\$${element}_${key}_${attr}
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

osr_get_drivers() {
   echo ""
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
  local nodeids_file=""
  if [ -f "$1" ]; then
    nodeids_file=$1
    shift
  fi
  local nodeid=""
  local mac=""
  local delim=" "
  local nodeids=""
  
  [ -z "$nodeids_file" ] && nodeids_file=$(osr_nodeids_file)
  test -f "$nodeids_file" || return 1
  while read nodeid mac; do
    nodeids=${nodeids}${delim}$nodeid
  done < $nodeids_file
  [ -n "$nodeids" ] && echo $nodeids
  [ -n "$nodeids" ]
  return $?
}

#
# osr_get_macs
#  returns all macs
osr_get_macs() {
  local nodeids_file=""
  if [ -f "$1" ]; then
    nodeids_file=$1
    shift
  fi
  local nodeid=""
  local mac=""
  local _mac=""
  local delim=" "
  local macs=""
  local none="none"
  
  [ -z "$nodeids_file" ] && nodeids_file=$(osr_nodeids_file)
  test -f "$nodeids_file" || return 1
  while read nodeid mac; do
  	if [ -z "$mac" ]; then
  	  continue
  	fi
  	for _mac in $mac; do
  	  if [ $_mac == $none ]; then
  	    continue
  	  fi
      macs=${macs}${delim}$_mac
  	done
  done < $nodeids_file
  [ -n "$macs" ] && echo $macs
  [ -n "$macs" ]
  return $?
}

#
# osr_get_nodeid([nodeids_file], mac) nodeidsfile macaddress
#   returns the nodeid of this macaddress
osr_get_nodeid() {
  local nodeids_file=""
  if [ -f "$1" ]; then
    nodeids_file=$1
    shift
  fi
  local _mac=$1
  local mac=""
  local macs=""
  
  local nodeid=""
  local delim=" "
  
  [ -z "$nodeids_file" ] && nodeids_file=$(osr_nodeids_file)
  test -f "$nodeids_file" || return 1
  while read nodeid macs; do
  	if [ -z "$macs" ]; then
  	  continue
  	fi
  	for mac in $macs; do
  	  if [ $_mac == $mac ]; then
  	    echo "$nodeid"
  	    return 0
  	  fi
  	done
  done < $nodeids_file
  return 1
}

#
# osr_get_nodename_by_id nodesconf nodeid nodeconf
#   Returns the nodename of this nodeid
osr_get_nodename_by_id() {
  local nodes_conf=""
  if [ -f "$1" ]; then
    nodes_conf=$1
    shift
  fi
  local nodeid=$1
  local nodeconf=$2
  [ -z $nodeconf ] && nodeconf=$(osr_nodeid_file $nodeid)

  osr_get_node_attrs "name" "name" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_rootvolume nodesconf nodeid nodeconf
#   Returns the nodename of this nodeid
osr_get_rootvolume() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "name" "rootvolume" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_rootsource nodesconf nodeid nodeconf
#   Returns the nodename of this nodeid
osr_get_rootsource() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "name" "rootsource" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_rootfs nodesconf nodeid nodeconf
#   Returns the nodename of this nodeid
osr_get_rootfs() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "fstype" "rootvolume" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_userspace_procs nodesconf nodeid nodename
osr_get_userspace_procs() {
  echo
}

#
# osr_get_mountopts nodesconf nodeid
osr_get_mountopts() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "mountopts" "rootvolume" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_chroot_mountpoint nodesconf nodeid
osr_get_chroot_mountpoint() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "mountpoint" "chrootenv" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_chroot_fstype nodesconf nodeid
osr_get_chroot_fstype() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "fstype" "chrootenv" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_chroot_device nodes_conf nodeid
osr_get_chroot_device() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "device" "chrootenv" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_chroot_mountopts nodes_conf nodeid
osr_get_chroot_mountopts() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "mountopts" "chrootenv" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_syslogserver nodes_conf nodeid
osr_get_syslogserver() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "name" "syslog" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_syslogfilter nodes_conf nodeid
osr_get_syslogfilter() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "filter" "syslog" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_scsifailover nodes_conf nodeid
osr_get_scsifailover() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "failover" "scsi" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get_netdevs nodes_conf nodeid
osr_get_netdevs() {
  local nodes_conf=""
  if [ -f "$1" ]; then
  	nodes_conf="$1"
  	shift
  fi
  local nodeid=$1
  local nodeconf=$2

  osr_get_node_attrs "name" "eth" "$nodeid" "" "" $nodes_conf "$nodeconf"
}

#
# osr_get [nodes_conf] query nodeid attrs
# Examples:
#   osr_get eth_name_name nodeid attr  
osr_get() {
  local nodesconf=""
  if [ -f "$1" ]; then
  	nodesconf="$1"
  	shift
  fi
  local query=$(osr_resolve_element_alias $1)
  local nodeid=$2
  local key=$3
  if [ -f "$4" ]; then
    nodeconf="$4"
    shift
  fi 
  [ -z "$nodeconf" ] && nodeconf=$(osr_nodeid_file $nodeid)
  
  local element=$(echo $query | cut -f1 -d_)
  local keyname=$(osr_get_cluster_element_key $element)
  
  if [ -n "$keyname" ] && [ -n "$key" ]; then
    query=$(echo $query | cut -f3- -d_)
  else
    query=$(echo $query | cut -f2- -d_)
  fi
  osr_get_node_attrs "$query" "$element" $nodeid "" "$key" $nodesconf $nodeconf
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
	test -f $(osr_nodeids_file)
}
#*********** osr_validate

#
# osr_auto_hosts
osr_auto_hosts() {
  local nodesconf=""
  local nodeid=""
  local netdev=""
  local nodename=""
  local ip=""
  
  if [ -f "$1" ]; then
  	nodesconf="$1"
  	shift
  fi
  local nodeconfpath=$1
  if [ -z "$nodeconfpath" ]; then
    nodeconfpath=$(dirname $(osr_nodeid_file 1))
  fi
  [ -z "$nodesconf" ] && nodesconf=$(osr_nodeids_file)
  
  for nodeid in $(osr_get_nodeids "$nodesconf"); do
    nodeconf=${nodeconfpath}/$(basename $(osr_nodeid_file $nodeid))
    nodename=$(osr_get "$nodesconf" name $nodeid "" "$nodeconf")
    for netdev in $(osr_get "$nodesconf" eth_name $nodeid ""); do
      if [ -n "$ip" ]; then
      	continue
      else
        ip=$(osr_get "$nodesconf" eth_name_ip $nodeid $netdev "$nodeconf")
        [ -n "$ip" ] && [ -n "$nodename" ] && echo "$ip $nodename"
      fi
    done  
  done 
}

[ -z "$cluster_conf" ] && cluster_conf=$(osr_nodeids_file)
repository_store_value osrquerymap /etc/comoonics/querymap.cfg 
