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
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    gfs-poolsource=... The poolsource possibilities (scsi*, gnbd)
#    gfs-pool=...       The gfs-pool to boot from
#    gfs-poolcca=... The gfs-cidev-pool to be given (defaults to ${gfspool}_cca, applies to 5.2)
#    gfs-poolcidev=... The gfs-cidev-pool to be given (defaults to ${gfspool}_cidev, applies to 5.1.1)
#    gfs-lockmethod=... The gfs-locking method (lock_gulm*, lock_dmep, nolock)
#    gfs-gnbdserver=.. The server serving the gnbd based scsi discs over ip
#    gfs-mountopt=...  The mount options given to the mount command (i.e. noatime,nodiratime)
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output

#****h* comoonics-bootimage/gfs-lib.sh
#  NAME
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#*******

[ -z "$default_lockmethod" ] && default_lockmethod="lock_dlm"
[ -z "$default_mountopts" ] && default_mountopts="noatime"
repository_has_key ccs_xml_query || repository_store_value ccs_xml_query "/usr/bin/com-queryclusterconf"
repository_has_key cl_check_nodes ||  repository_store_value cl_check_nodes "/usr/bin/cl_checknodes"

#****d* boot-scripts/etc/gfs-lib.sh/cluster_conf
#  NAME
#    cluster_conf
#  DESCRIPTION
#    clusterconfig file defaults to /etc/cluster/cluster.conf
#    will implicitly be stored in cluster_conf repository
[ -z "$cluster_conf" ] && cluster_conf=$(getParameter cluster_conf "/etc/cluster/cluster.conf")
#******** cluster_conf

#if [ ! -e $cluster_conf ]; then
#  error_local "Critical error could not find cluster configuration."
#  exit_linuxrc 1
#fi

#clutype="gfs"

#****f* gfs-lib.sh/getGFSMajorVersion
#  NAME
#    getGFSMajorVersion
#  SYNOPSIS
#    getGFSMajorVersion
#  DESCRIPTION
#    returns the gfs-majorversion
#  IDEAS
#  SOURCE
#
function getGFSMajorVersion() {
    modinfo gfs | awk '$1 == "description:" {
  match($5, /v([[:digit:]]+)\./, version);
  print version[1];
}'
}
#************ getGFSMajorVersion

#****f* gfs-lib.sh/getGFSMinorVersion
#  NAME
#    getGFSMinorVersion
#  SYNOPSIS
#    getGFSMinorVersion
#  DESCRIPTION
#    returns the gfs-minorversion
#  IDEAS
#  SOURCE
#
function getGFSMinorVersion() {
    modinfo gfs | awk '$1 == "description:" {
  match($5, /v[[:digit:]]+\.([[:digit:]]+)/, version);
  print version[1];
}'
}
#********* getGFSMinorVersion

#****f* boot-scripts/etc/clusterfs-lib.sh/gfs_getdefaults
#  NAME
#    gfs_getdefaults
#  SYNOPSIS
#    gfs_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function gfs_getdefaults() {
	local param=$1
	local distribution=$(repository_get_value distribution)
	
	case "$param" in
		lock_method|lockmethod)
		    echo "lock_dlm"
		    ;;
		mount_opts|mountopts)
		    echo "noatime,localflocks"
		    ;;
		root_source|rootsource)
		    echo "scsi"
		    ;;
		rootfs|root_fs)
			if [ -n "$distribution" ]; then
	          if [ ${distribution:0:4} = "sles" ]; then
	            echo "ocfs2"
			  else
			    echo "gfs"
	          fi
            else 
		      echo "gfs"
            fi
		    ;;
	    scsi_failover|scsifailover)
	        echo "driver"
	        ;;
	    ip)
	        echo "cluster"
	        ;;
	    *)
	        return 0
	        ;;
	esac
}
#********** clusterfs_getdefaults

# helper function to call the cluster query command
# ccs_xml_query query
function ccs_xml_query {
   local cluster_conf=$(repository_get_value cluster_conf)
   local query_map=$(repository_get_value osrquerymap)
   local xml_cmd=$(repository_get_value ccs_xml_query)
   local opts=
   
   [ -n "$cluster_conf" ] && opts="--filename $cluster_conf"
   [ -n "$query_map" ] && opts="$opts --querymapfile $query_map"

   $xml_cmd $opts $@
}	

#****f* clusterfs-lib.sh/gfs_validate
#  NAME
#    gfs_validate
#  SYNOPSIS
#    gfs_validate(xml_cmd)
#  DESCRIPTION
#    validates the cluster configuration.
#    Both cluster.conf and $ccs_xml_query are guessed from the repository. 
#  SOURCE
function gfs_validate() {
  local cluster_conf=$(repository_get_value cluster_conf /etc/cluster/cluster.conf)
  # either cluster_conf exists which should be default or it is pregenerated
  if [ -f "$cluster_conf" ]; then
    errors=$(ccs_xml_query -q nodeids 2>&1 >/dev/null)
    if [ -n "$errors" ]; then
  	  return 1
    else
      return 0
    fi
  fi
  return 1
}
#*********** cc_validate

#****f* boot-scripts/etc/clusterfs-lib.sh/gfs_get
#  NAME
#    gfs_get
#  SYNOPSIS
#    gfs_get opts
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
gfs_get() {
	ccs_xml_query -q "$@"
}
# *********** gfs_get

#****f* boot-scripts/etc/clusterfs-lib.sh/gfs_get_clustername
#  NAME
#    gfs_get_clustername
#  SYNOPSIS
#    gfs_get_clustername()
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
gfs_get_clustername() {
   gfs_get clustername_name	
}
# *********** gfs_get_clustername

#****f* boot-scripts/etc/clusterfs-lib.sh/gfs_convert
#  NAME
#    gfs_convert
#  SYNOPSIS
#    gfs_convert(clustertype)
#  DESCRIPTTION
#    converts the current cluster configuration to the specified type.
#    Currently only supported for ocfs2 cluster configuration.
#  SOURCE
#
gfs_convert() {
   ccs_xml_query convert ${1:-$(repository_get_value rootfs)}
}
# *********** gfs_convert

#****f* boot-scripts/etc/clusterfs-lib.sh/gfs_get_rootfs
#  NAME
#    gfs_get_rootfs
#  SYNOPSIS
#    gfs_get_rootfs(nodeidornodename)
#  DESCRIPTTION
#    returns the type of the root filesystem.
#  SOURCE
#
function gfs_get_rootfs() {
   gfs_get rootvolume_fstype "$@"
}
#******** gfs_get_rootfs

#****f* gfs-lib.sh/gfs_get_rootvolume
#  NAME
#    gfs_get_rootvolume
#  SYNOPSIS
#    gfs_get_rootvolume(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the rootvolume for this node
#  IDEAS
#  SOURCE
#
function gfs_get_rootvolume() {
   gfs_get rootvolume_name "$@"
}
#************ gfs_get_rootvolume

#****f* gfs-lib.sh/gfs_get_mountopts
#  NAME
#    gfs_get_mountopts
#  SYNOPSIS
#    gfs_get_mountopts(nodenameorid)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function gfs_get_mountopts() {
   gfs_get rootvolume_mountopts "$@"
}
#************ gfs_get_mountopts

#****f* gfs-lib.sh/gfs_get_rootsource
#  NAME
#    gfs_get_rootsource
#  SYNOPSIS
#    gfs_get_rootsource(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the rootsource for this node
#  IDEAS
#  SOURCE
#
function gfs_get_rootsource() {
   gfs_get rootsource_name "$@"
}
#************ gfs_get_rootsource

#****f* gfs-lib.sh/gfs_get_chroot_mountpoint
#  NAME
#    gfs_get_chroot_mountpoint
#  SYNOPSIS
#    gfs_get_chroot_mountpoint(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountpoint for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_mountpoint() {
   gfs_get chrootenv_mountpoint "$@"
}
#************ gfs_get_chroot_mountpoint

#****f* gfs-lib.sh/gfs_get_chroot_fstype
#  NAME
#    gfs_get_chroot_fstype
#  SYNOPSIS
#    gfs_get_chroot_fstype(nodename)
#  DESCRIPTION
#    Gets the filesystem type for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_fstype() {
   gfs_get chrootenv_fstype "$@"
}
#************ gfs_get_chroot_fstype

#****f* gfs-lib.sh/gfs_get_chroot_device
#  NAME
#    gfs_get_chroot_device
#  SYNOPSIS
#    gfs_get_chroot_device(nodenameorid)
#  DESCRIPTION
#    Gets the mountpoint for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_device() {
   gfs_get chrootenv_device "$@"
}
#************ gfs_get_chroot_device

#****f* gfs-lib.sh/gfs_get_chroot_mountopts
#  NAME
#    gfs_get_chroot_mountopts
#  SYNOPSIS
#    gfs_get_chroot_mountopts(nodenameorid)
#  DESCRIPTION
#    Gets the mount options for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_mountopts() {
   gfs_get chrootenv_mountopts "$@"
}
#************ gfs_get_chroot_mountopts

#****f* gfs-lib.sh/gfs_get_chroot_dir
#  NAME
#    gfs_get_chroot_dir
#  SYNOPSIS
#    gfs_get_chroot_dir(nodename)
#  DESCRIPTION
#    Gets the directory for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_dir() {
   gfs_get chrootenv_chrootdir "$@"
}
#************ gfs_get_chroot_dir

#****f* gfs-lib.sh/gfs_get_scsifailover
#  NAME
#    gfs_get_scsifailover
#  SYNOPSIS
#    gfs_get_scsifailover(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function gfs_get_scsifailover() {
   gfs_get scsi_failover "$@"
}
#************ gfs_get_scsifailover

#****f* gfs-lib.sh/gfs_get_nodename
#  NAME
#    gfs_get_nodename
#  SYNOPSIS
#    gfs_get_nodename(hwid)
#  DESCRIPTION
#    gets for this very host the nodename (identified by the macaddress)
#  IDEAS
#  SOURCE
#
function gfs_get_nodename() {
	gfs_get nodename_by_hwid "$@"
}
#************ gfs_get_nodename

#****f* gfs-lib.sh/gfs_get_nodename_by_id
#  NAME
#    gfs_get_nodename_by_id
#  SYNOPSIS
#    gfs_get_nodename_by_id(id)
#  DESCRIPTION
#    gets for this very host the nodename (identified by the nodeid)
#  IDEAS
#  SOURCE
#
function gfs_get_nodename_by_id() {
	gfs_get nodename_by_id "$@"
}
#************ gfs_get_nodename

#****f* gfs-lib.sh/gfs_get_nodeids
#  NAME
#    gfs_get_nodeids
#  SYNOPSIS
#    gfs_get_nodeids(cluster_conf, mac)
#  DESCRIPTION
#    gets for this very host the nodeid (identified by the macaddress)
#  IDEAS
#  SOURCE
#
function gfs_get_nodeids() {
	gfs_get nodeids "$@" 
}
#************ gfs_get_nodeids

#****f* gfs-lib.sh/gfs_get_macs
#  NAME
#    gfs_get_hwids
#  SYNOPSIS
#    gfs_get_hwids()
#  DESCRIPTION
#    gets all hwids addresses found in the cluster configuration
#  IDEAS
#  SOURCE
#
function gfs_get_hwids() {
	get_gfs hwids "$@"
}
#************ gfs_get_macs

#****f* gfs-lib.sh/gfs_get_nodeid
#  NAME
#    gfs_get_nodeid
#  SYNOPSIS
#    gfs_get_nodeid(cluster_conf, mac)
#  DESCRIPTION
#    gets for this very host the nodeid (identified by the macaddress)
#  IDEAS
#  SOURCE
#
function gfs_get_nodeid() {
	gfs_get nodeid_by_hwid "$@"
}
#************ gfs_get_nodeid

#****f* gfs-lib.sh/gfs_get_netdevs
#  NAME
#    gfs_get_netdevs
#  SYNOPSIS
#    gfs_get_netdevs(nodenameorid)
#  DESCRIPTION
#    returns all configured networkdevices from the cluster.conf xml file
#    seperated by " "
#  IDEAS
#  SOURCE
#
function gfs_get_netdevs() {
  gfs_get eth_name "$@"
}
#********* gfs_get_netdevs

#****f* gfs-lib.sh/gfs_auto_hosts
#  NAME
#    gfs_auto_hosts
#  SYNOPSIS
#    gfs_auto_hosts(hostsfile)
#  DESCRIPTION
#    Generates a hostsfile of all hosts in the cluster configuration
#  IDEAS
#  SOURCE
#
function gfs_auto_hosts() {
    local hostsfile=$1

#    if [ -n "$debug" ]; then set -x; fi
#    cp -f $hostsfile $hostsfile.bak
    ccs_xml_query -f $xmlfile -q hosts
    cat $hostsfile
    ret=$?
#    if [ -n "$debug" ]; then set +x; fi
    return $ret
}
#************ gfs_auto_hosts

#****f* gfs-lib.sh/gfs_get_syslogserver
#  NAME
#    gfs_get_syslogserver
#  SYNOPSIS
#    gfs_get_syslogserver(nodeidornodename)
#  DESCRIPTION
#    This Function starts the syslog-server to log the gfs-bootprocess
#  IDEAS
#  SOURCE
#
function gfs_get_syslogserver() {
  gfs_get syslog_name "$@"
}
#************ gfs_get_syslogserver

#****f* gfs-lib.sh/gfs_get_syslogfilter
#  NAME
#    gfs_get_syslogfilter
#  SYNOPSIS
#    gfs_get_syslogfilter(cluster_conf)
#  DESCRIPTION
#    This Function starts the syslog-server to log the gfs-bootprocess
#  IDEAS
#  SOURCE
#
function gfs_get_syslogfilter() {
  gfs_get syslog_filter "$@"
}
#************ gfs_get_syslogfilter

#****f* gfs-lib.sh/gfs_get_nic_names
#  NAME
#    gfs_get_nic_names
#  SYNOPSIS
#    gfs_get_nic_names(nodeidornodename,)
#  DESCRIPTION
#    Returns the nic drivers for the given node if specified in cluster configuration.
#    If node is left out all drivers will be returned. 
#  SOURCE
function gfs_get_nic_names() {
	gfs_get_node_attrs "name" "eth" "$@"
}
#*********** gfs_get_nic_names

#****f* gfs-lib.sh/gfs_get_nic_drivers
#  NAME
#    gfs_get_nic_drivers
#  SYNOPSIS
#    gfs_get_nic_drivers(nodeid, nodename, nic, clusterconf)
#  DESCRIPTION
#    Returns the nic drivers for the given node if specified in cluster configuration.
#    If node is left out all drivers will be returned. 
#  SOURCE
function gfs_get_nic_drivers() {
	gfs_get_node_attrs "driver" "eth" "$@"
}
#*********** gfs_get_nic_drivers

#****f* gfs-lib.sh/gfs_get_nic_drivers
#  NAME
#    gfs_get_nic_drivers
#  SYNOPSIS
#    gfs_get_nic_drivers(nodeid, nodename, name, clusterconf)
#  DESCRIPTION
#    Returns the nic drivers for the given node if specified in cluster configuration.
#    If node is left out all drivers will be returned. 
#  SOURCE
function gfs_get_all_drivers() {
	gfs_get_node_attrs "driver" "eth" "$@"
}
#*********** gfs_get_nic_drivers

#****f* gfs-lib.sh/gfs_get_node_attrs
#  NAME
#    gfs_get_node_attrs
#  SYNOPSIS
#    gfs_get_node_attrs(attr, subpath, nodeidornodename, name)
#  DESCRIPTION
#    Returns the drivers for the given node if specified in cluster configuration.
#    If node is left out all drivers will be returned. 
#  SOURCE
function gfs_get_node_attrs() {
  local attr=$1
  local subpath=$2
  local nodeid=$3
  local name=$4
  
  local query=""
  if [ -n "$name" ]; then
  	subquery="[@name=\"$name\"]"
  fi
  local xml_cmd_opts="--queriesfile=- --suffix=;"
  local out=$(
  if [ -z "$nodeid" ]; then
    echo "query=query_value /cluster/clusternodes/clusternode/com_info/${subpath}$subquery/@$attr"
  else
    echo "query=query_value /cluster/clusternodes/clusternode[@nodeid=\"$nodeid\"]/com_info/${subpath}$subquery/@$attr"
    echo "query=query_value /cluster/clusternodes/clusternode[@name=\"$nodeid\"]/com_info/${subpath}$subquery/@$attr"
  fi | ccs_xml_cmd $xml_cmd_opts | cut -f1 -d';')
  if [ -z "$out" ]; then
  	return 1
  else
    echo $out
  fi
}
#*********** gfs_get_node_attrs

#****f* gfs-lib.sh/gfs_get_userspace_procs
#  NAME
#    gfs_get_userspace_procs
#  SYNOPSIS
#    gfs_get_userspace_procs()
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function gfs_get_userspace_procs() {
  echo -e "aisexec \n\
ccsd \n\
fenced \n\
gfs_controld \n\
dlm_controld \n\
groupd \n\
qdiskd \n\
clvmd"
}
#******** gfs_get_userspace_procs

#****f* gfs-lib.sh/gfs_get_drivers
#  NAME
#    gfs_get_drivers
#  SYNOPSIS
#    gfs_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function gfs_get_drivers() {
	echo "dlm lock_dlm gfs gfs2 configfs lock_nolock"
}
#*********** gfs_get_drivers

#****f* gfs-lib.sh/gfs_load
#  NAME
#    gfs_load
#  SYNOPSIS
#    gfs_load(lockmethod)
#  DESCRIPTION
#    This Function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs_load() {
  ## THIS will be overwritten for rhel5 ##
  local lock_method=$1

  GFS_MODULES="gfs cman"

  case $lock_method in
    lock_dlm)
      GFS_MODULES="${GFS_MODULES} lock_dlm"
      ;;
    lock_gulm)
      GFS_MODULES="${GFS_MODULES} lock_gulm"
      ;;
    *)
      GFS_MODULES="${GFS_MODULES} lock_dlm"
      ;;
  esac

  echo_local -n "Loading GFS modules ($GFS_MODULES)..."
  for module in ${GFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ gfs_load

#****f* gfs-lib.sh/gfs_services_start
#  NAME
#    gfs_services_start
#  SYNOPSIS
#    gfs_services_start(lockmethod)
#  DESCRIPTION
#    This Function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs_services_start() {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1
  local lock_method=$2
  local lvm_sup=$3

  setHWClock

  services="ccsd $lock_method cman qdiskd fenced"
  if [ -n "$lvm_sup" ] && [ $lvm_sup -eq 0 ]; then
  	services="$services clvmd"
  fi
  for service in $services; do
    gfs_start_$service $chroot_path
    if [ $? -ne 0 ]; then
      return $?
    fi
  done
  return $return_c
}
#************ gfs_services_start

#****f* gfs-lib.sh/gfs_services_restart_newroot
#  NAME
#    gfs_services_restart_newroot
#  SYNOPSIS
#    gfs_services_restart_newroot()
#  DESCRIPTION
#    This Function starts all needed services in newroot
#  IDEAS
#  SOURCE
#
function gfs_services_restart_newroot() {
  ## THIS will be overwritten for rhel5 ##
  exec_local /bin/true
}
#************ gfs_services_restart_newroot

#****f* gfs-lib.sh/gfs_services_restart
#  NAME
#    gfs_services_restart
#  SYNOPSIS
#    gfs_services_restart(lockmethod)
#  DESCRIPTION
#    This Function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs_services_restart() {
  local old_root=$1
  local new_root=$2

  services="ccsd fenced"
  for service in $services; do
    gfs_restart_$service $old_root $new_root
    if [ $? -ne 0 ]; then
      echo $service > $new_root/${cdsl_local_dir}/FAILURE_$service
#      return $?
    fi
  done
  return $return_c
}
#************ gfs_services_restart

#****f* gfs-lib.sh/gfs_start_lock_dlm
#  NAME
#    gfs_start_lock_dlm
#  SYNOPSIS
#    gfs_start_lock_dlm
#  DESCRIPTION
#    Function starts the lock_dlm in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_lock_dlm() {
  return 0
}
#************ gfs_start_lock_dlm

#****f* gfs-lib.sh/gfs_start_cman
#  NAME
#    gfs_start_cman
#  SYNOPSIS
#    gfs_start_cman
#  DESCRIPTION
#    Function starts the cman in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_cman() {
  local cmd="cman_tool join -w"
  
  if repository_has_key votes; then
  	local votes=$(repository_get_value votes)
  	cmd="$cmd -v $votes"
	echo_local_debug "Votes value has been set to $votes"
  fi

  echo_local "Joining the cluster manager"
  sleep 5
  start_service_chroot $chroot_path $cmd
  if [ -n "$votes" ]; then
	start_service_chroot $chroot_path cman_tool votes -v $votes
  fi
  touch $chroot_path/var/lock/subsys/cman 2>/dev/null
  return $return_c
#  return_code
}
#************ gfs_start_cman

#****f* gfs-lib.sh/gfs_stop_cman
#  NAME
#    gfs_stop_cman
#  SYNOPSIS
#    gfs_stop_cman
#  DESCRIPTION
#    Function stops the cman in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_stop_cman() {
  echo_local -n "Leaving the cluster"
  exec_local cman_tool leave remove -w ||
  exec_local cman_tool leave force
  return_code
}
#************ gfs_stop_cman

#****f* gfs-lib.sh/gfs_start_fenced
#  NAME
#    gfs_start_fenced
#  SYNOPSIS
#    gfs_start_fenced() {
#  DESCRIPTION
#    Function starts the fenced in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_fenced() {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1
  #start_service_chroot $chroot_path 'fenced -c'
  start_service_chroot $chroot_path '/sbin/fence_tool -c -w join' && \
  touch $chroot_path/var/lock/subsys/fenced 2>/dev/null
  return_code
}
#************ gfs_start_fenced

#****f* gfs-lib.sh/gfs_stop_fenced
#  NAME
#    gfs_stop_fenced
#  SYNOPSIS
#    gfs_stop_fenced()
#  DESCRIPTION
#    Function stops the fenced in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_stop_fenced() {
  local chroot_path=$1
  echo_local -n "stopping fenced"
  exec_local '/sbin/fence_tool leave -w' && \
  rm $chroot_path/var/lock/subsys/fenced 2>/dev/null
  return_code
}
#************ gfs_start_fenced

#****f* gfs-lib.sh/gfs_start_ccsd
#  NAME
#    gfs61_start_ccsd
#  SYNOPSIS
#    gfs_start_ccsd
#  DESCRIPTION
#    Function starts the ccsd in nochroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_ccsd() {
  local chroot_path=$1
  start_service_chroot $chroot_path /sbin/ccsd && \
  touch $chroot_path/var/lock/subsys/ccsd 2>/dev/null
  return $return_c
}

#************ gfs_start_ccsd

#****f* gfs-lib.sh/gfs_restart_ccsd
#  NAME
#    gfs_restart_ccsd
#  SYNOPSIS
#    gfs_restart_ccsd(old_root, new_root)
#  DESCRIPTION
#    Function restarts the ccsd for removing the deps on /initrd
#  IDEAS
#  SOURCE
#
function gfs_restart_ccsd() {
   old_root=$1
   new_root=$2

#   set -x
   echo_local -n "Restarting ccsd ($old_root=>$new_root) "$(pwd)
   [ -e ${old_root}/var/run/cluster/ccsd.pid ] &&
   kill $(cat ${old_root}/var/run/cluster/ccsd.pid) &&
   rm ${old_root}/var/run/cluster/ccsd.pid &&
   rm -rf ${new_root}/var/run/cluster &&
   mkdir ${new_root}/var/run/cluster
   echo_local -n ".(kill)."
   if [ $? -ne 0 ]; then
      pids=$(ps ax | grep ccsd | awk '$5!="grep" { print $1; }')
      if [ -n "$pids" ]; then
        kill $pids
      fi
      pids=$(ps ax | grep ccsd | awk '$5!="grep" { print $1; }')
      if [ -n "$pids" ]; then
        kill -9 $pids
      fi
    fi
    chroot $new_root /sbin/ccsd &&
    echo_local -n ".(start)."
    return_code $?
}
#******gfs_restart_ccsd

#****f* gfs-lib.sh/gfs_start_clvmd
#  NAME
#    gfs_start_clvmd
#  SYNOPSIS
#    gfs_start_clvmd(chroot)
#  DESCRIPTION
#    Function starts the clvmd in a chroot environment
#  IDEAS
#  SOURCE
#
#TODO: Remove the hotspots
function gfs_start_clvmd() {
   local chroot_path=$1
   local volumegroup=$(lvm_get_vg $(repository_get_value root))

   [ -d "${chroot_path}/var/run/lvm" ] || mkdir -p ${chroot_path}/var/run/lvm 
   #echo_local -n "Starting clvmd ($chroot_path) "
   start_service_chroot $chroot_path /usr/sbin/clvmd
#   return_code $?
   sleep 10
   echo_local -n "Activating VGs:"
   exec_local_stabilized 3 5 chroot $chroot_path /sbin/lvm vgscan --mknodes >/dev/null 2>&1
   exec_local_stabilized 3 5 chroot $chroot_path /sbin/lvm vgchange -ay $volumegroup >/dev/null 2>&1
   if [ -e /dev/urandom ]; then 
     exec_local_stabilized 3 5 /sbin/lvm vgscan --mknodes >/dev/null 2>&1
     exec_local_stabilized 3 5 /sbin/lvm vgchange -ay $volumegroup >/dev/null 2>&1
   fi
   return_code $?
   touch $chroot_path/var/lock/subsys/clvmd 2>/dev/null
   return $return_c
}
#******gfs_start_clvmd

#****f* gfs-lib.sh/gfs_stop_clvmd
#  NAME
#    gfs_stop_clvmd
#  SYNOPSIS
#    gfs_stop_clvmd(chroot)
#  DESCRIPTION
#    Function stops the clvmd in a chroot environment
#  IDEAS
#  SOURCE
#
function gfs_stop_clvmd() {
   chroot_path=$1

   echo_local -n "Stopping clvmd ($chroot_path) "
   exec_local killall clvmd
   if pidof clvmd > /dev/null; then
       killall -9 clvmd
   fi
   return_code $?
   sleep 10
   rm $chroot_path/var/lock/subsys/clvmd 2>/dev/null
   return $return_c
}
#******gfs_stop_clvmd

#****f* gfs-lib.sh/gfs_restart_clvmd
#  NAME
#    gfs_restart_clvmd
#  SYNOPSIS
#    gfs_restart_clvmd(old_root, new_root)
#  DESCRIPTION
#    Function restarts the clvmd for removing the deps on /initrd
#  IDEAS
#  SOURCE
#
#TODO: Remove the hostspots
function gfs_restart_clvmd() {
   local old_root=$1
   local new_root=$2
   local volumegroup=$(lvm_get_vg $(repository_get_value root))

#   set -x
   echo_local -n "Starting clvmd ($new_root) "$(pwd)
   chroot $new_root /usr/sbin/clvmd
   return_code $?
   echo_local -n "ActivatinActivating VGs:"
   chroot $new_root /sbin/vgscan --mknodes >/dev/null 2>&1
   chroot $new_root /sbin/vgchange -ayl $volumegroup >/dev/null 2>&1
   return_code $?
}
#******gfs_restart_clvmd

#****f* gfs-lib.sh/gfs_restart_fenced
#  NAME
#    gfs_restart_fenced
#  SYNOPSIS
#    function gfs_restart_fenced(old_root, new_root)
#  DESCRIPTION
#    Function restarts the fenced for removing the deps on /initrd
#  IDEAS
#  SOURCE
#
function gfs_restart_fenced() {
   old_root=$1
   new_root=$2

   echo_local -n "Restarting fenced ($old_root=>$new_root) "
   [ ! -d ${new_root}/cluster/shared/var/lib/fence_tool ] && mkdir -p ${new_root}/cluster/shared/var/lib/fence_tool
   mount -t tmpfs none ${new_root}/cluster/shared/var/lib/fence_tool &&
   echo_local -n ".(mount)." &&
   cp -a ${old_root}/var/lib/fence_tool/* ${new_root}/cluster/shared/var/lib/fence_tool &&
   echo_local -n ".(cp)." &&
   kill $(cat ${old_root}/var/lib/fence_tool/var/run/fenced.pid) &&
   echo_local -n ".(kill)." &&
   rm ${old_root}/var/lib/fence_tool/var/run/fenced.pid
   if [ $? -ne 0 ]; then
     pids=$(ps ax | grep fenced | awk '$5!="grep" { print $1; }')
     if [ -n "$pids" ]; then
       kill $pids
     fi
     pids=$(ps ax | grep fenced | awk '$5!="grep" { print $1; }')
     if [ -n "$pids" ]; then
       kill -9 $pids
     fi
   fi &&
   chroot ${new_root}/cluster/shared/var/lib/fence_tool /sbin/fenced
   error_code=$?
   return_code $error_code
#   set +x

   return $error_code
}
#************ gfs_restart_fenced

#****f* gfs-lib.sh/gfs_start_qdiskd
#  NAME
#    gfs_start_qdiskd
#  SYNOPSIS
#    gfs_start_qdiskd
#  DESCRIPTION
#    Function starts the qdiskd in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_qdiskd() {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1

  cmd=$(chroot $chroot_path which qdiskd)
  $ccs_xml_query query_xml /cluster/quorumd >/dev/null 2>&1
  if [ $? -eq 0 ] && [ -n "$cmd" ]; then
     start_service_chroot $chroot_path $cmd -Q && \
     touch $chroot_path/var/lock/subsys/qdisk 2>/dev/null
  else
  	 echo_local -n "Starting qdiskd"
     passed
     echo_local
  fi
  return $return_c
}
#************ gfs_start_qdiskd

#****f* gfs-lib.sh/gfs_stop_qdiskd
#  NAME
#    gfs_stop_qdiskd
#  SYNOPSIS
#    gfs_stop_qdiskd
#  DESCRIPTION
#    Function starts the qdiskd in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_stop_qdiskd() {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1

  local cmd="qdiskd"
  $ccs_xml_query query_xml /cluster/quorumd >/dev/null 2>&1
  if [ $? -eq 0 ] && [ -n "$cmd" ]; then
  	 echo_local -n "Stopping qdiskd"
     stop_service $cmd $chroot_path && \
     success && \
     rm $chroot_path/var/lock/subsys/qdisk 2>/dev/null
     echo_local
  else
  	 echo_local -n "Stopping qdiskd"
     passed
     echo_local
  fi
  return $return_c
}
#************ gfs_stop_qdiskd

#****f* gfs-lib.sh/gfs_start_groupd
#  NAME
#    gfs_start_groupd
#  SYNOPSIS
#    gfs_start_groupd
#  DESCRIPTION
#    Function starts the groupd in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_groupd() {
  local chroot_path=$1
  start_service_chroot $chroot_path  /sbin/groupd && \
  touch $chroot_path/var/lock/subsys/groupd 2>/dev/null
  return $return_c
}
#************ gfs_start_groupd

#****f* gfs-lib.sh/gfs_start_dlm_controld
#  NAME
#    gfs_start_dlm_controld
#  SYNOPSIS
#    gfs_start_dlm_controld
#
#  DESCRIPTION
#    Function starts the dlm_controld in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_dlm_controld() {
  local chroot_path=$1
  start_service_chroot $chroot_path /sbin/dlm_controld && \
  touch $chroot_path/var/lock/subsys/dlmcontrold 2>/dev/null
  return $return_c
}
#************ gfs_start_dlm_controld

#****f* gfs-lib.sh/gfs_start_gfs_controld
#  NAME
#    gfs_start_gfs_controld
#  SYNOPSIS
#    gfs_start_gfs_controld
#
#  DESCRIPTION
#    Function starts the gfs_controld in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_gfs_controld() {
  local chroot_path=$1
  start_service_chroot $chroot_path /sbin/gfs_controld && \
  touch $chroot_path/var/lock/subsys/gfscontrold 2>/dev/null
  return $return_c
}
#************ gfs_start_gfs_controld



#****f* gfs-lib.sh/gfs_checkhosts_alive
#  NAME
#    gfs_checkhosts_alive
#  SYNOPSIS
#    gfs_checkhosts_alive()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function gfs_checkhosts_alive() {
    $(repository_get_value cl_check_nodes)
}
#********* gfs_checkhosts_alive

#****f* gfs-lib.sh/gfs_init
#  NAME
#    gfs_init
#  SYNOPSIS
#    gfs_init(start|stop|restart) rootfs CHROOT_PATH 
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function gfs_init() {
	local action=$1
	local CHROOT_PATH=$2
	local rootfs="gfs"
	local VAR_RUN_FILES="cluster/ccsd.pid cluster/ccsd.sock cman_admin cman_client"
	
	case "$action" in
        start)
           /bin/mount -at $rootfs 2>&1 | tee -a /var/log/bootsr | logger -t com-bootsr
           # Create symbolic links
           for file in ${VAR_RUN_FILES}; do
  	          [ -e /var/run/${file} ] && rm -f /var/run/${file}
  	          test -d /var/run/$(dirname ${file}) || mkdir -p /var/run/$(dirname ${file}) 2>/dev/null
  	          test -e ${CHROOT_PATH}/var/run/${file} && /bin/ln -sf ${CHROOT_PATH}/var/run/${file} /var/run/$(dirname $file)
           done
           ;;
         stop)
           ;;
    esac
	return 0
}
#********* gfs_init

#****f* gfs-lib.sh/gfs_fsck_needed
#  NAME
#    gfs_fsck_needed
#  SYNOPSIS
#    gfs_fsck_needed(root, rootfs)
#  DESCRIPTION
#    Will always return 1 for no fsck needed. This can only be triggered by rootfsck 
#    bootoption.
#
function gfs_fsck_needed() {
	return 1
}
#********* gfs_fsck_needed

#****f* gfs-lib.sh/gfs_fsck
#  NAME
#    gfs_fsck
#  SYNOPSIS
#    gfs_fsck_needed(root, rootfs)
#  DESCRIPTION
#    If this Function is called. It will always execute an gfsfsck on the given root.
#    Be very very carefull with this Function!!
#
function gfs_fsck() {
	local root="$1"
	local fsck="fsck.gfs"
	local options="-y"
	echo_local -n "Calling $fsck on filesystem $root"
	exec_local $fsck $options $root
	return_code
}
#********* gfs_fsck

# for gfs we need a chroot
function gfs_chroot_needed() {
	return 0
}
