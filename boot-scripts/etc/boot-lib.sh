#
# $Id: boot-lib.sh,v 1.1 2004-07-31 11:24:43 marc Exp $
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
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output

LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/lib/i686:/usr/lib"
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH LD_LIBRARY_PATH

bootlog="/var/log/comoonics-boot.log"
# the disk where the bootlog should be written to (default /dev/fd0).
diskdev="/dev/fd0"

function step() {
   if [ ! -z "$stepmode" ]; then
     echo -n "Press <RETURN> to continue ..."
     read
   else
     sleep 1
   fi
}
function getBootParm() {
   parm="$1"
   default="$2"
   cmdline=`cat /proc/cmdline`
   out=`expr "$cmdline" : ".*$parm=\([^ ]*\)"`
   if [ -z "$out" ]; then out="$default"; fi
   echo "$out"
}

function getShortRelease() {
  if [ -e /etc/redhat-release ]; then
    echo "redhat"
  elif [ -e /etc/SuSE-release ]; then
    echo "SuSE"
  else
    echo "Unknown"
  fi
}

function getRelease() {
   cat /etc/$(getShortRelease)-release
}

function my_ifup() {
   local dev=$1
   modprobe $dev && sleep 2 && ifconfig $dev up && sleep 2 && ifup $dev
   return $?
}

function getPosFromIPString() {
  pos=$1
  str=$2
  echo $str | awk -v pos=$pos 'BEGIN { FS=":"; }{ print $pos; }'
}

function generateSuSEIfCfg() {
  local ipAddr=$1
  local ipGate=$2
  local ipNetmask=$3
  local ipHostname=$4
  local ipDevice=$5

  awkfile="/etc/sysconfig/network/ifcfg.template.awk"
  # just for testing
  local __prefix="/tmp"

  if [ -z "$ipHostname" ]; then hostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then 
    bootproto="dhcp"
  else 
    bootproto="static"
  fi

  if [ "$ipAddr" != "dhcp" ]; then 
      hostname=$(expr match "$ipAddr" '\([^.]*\).')
      domainname=$(expr match "$ipAddr" '[^.]*.\(.*\)$')
  
      /bin/hostname $hostname
      /bin/domainname $domainname
      echo $hostname > /etc/HOSTNAME
      echo $domainname > /etc/defdomain
  fi

  awk -F'=' -f $awkfile bootproto="$bootproto" ipaddr="$ipAddr" netmask="$ipNetmask" startmode="onboot" > /etc/sysconfig/network/ifcfg-$ipDevice
  if [ "$ipAddr" != "dhcp" ]; then 
      echo "default $ipGate - -" >> /etc/sysconfig/network/routes
      echo_local_debug "2.1.2 /etc/sysconfig/network-scripts/routes"
      exec_local_debug cat /etc/sysconfig/network/routes
  fi

  echo_local_debug "2.1.1 /etc/sysconfig/network/ifcfg-$ipDevice"
  exec_local_debug cat /etc/sysconfig/network/ifcfg-$ipDevice
  return 0
}

function generateRedHatIfCfg() {
  local ipAddr=$1
  local ipGate=$2
  local ipNetmask=$3
  local ipHostname=$4
  local ipDevice=$5

  # just for testing
  #local $pref="/tmp"

  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  # first save
  if [ -e ${__prefix}/etc/sysconfig/network ]; then
    mv ${__prefix}/etc/sysconfig/network ${__prefix}/etc/sysconfig/network.com_back
  fi
  if [ -e ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ]; then
    mv ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ${__prefix}/etc/sysconfig/network-scripts/ifcfg-${pDevice}.com_back
  fi
  if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then 
    bootproto="dhcp"
  else 
    bootproto="static"
  fi
  (echo "DEVICE=$ipDevice" && 
   echo "BOOTPROTO=$bootproto" && 
   echo "ONBOOT=yes") > ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
  if [ "$bootproto" != "dhcp" ]; then
     (echo "IPADDR=$ipAddr" && 
	 if [ -n "$ipNetmask" ]; then echo "NETMAKS=$ipNetmask"; fi) >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     (if [ -n "$ipGate" ]; then echo "GATEWAY=$ipGate"; fi ) >> ${__prefix}/etc/sysconfig/network
   fi
   (echo "NETWORKINGO=yes" &&
    echo "HOSTNAME=$ipHostname") > ${__prefix}/etc/sysconfig/network
   if [ $(/bin/hostname) = "(none)" ]; then /bin/hostname $ipHostname; fi
   echo_local_debug "2.1.1 /etc/sysconfig/network"
   exec_local_debug cat /etc/sysconfig/network
   echo_local_debug "2.1.2 /etc/sysconfig/network-scripts/ifcfg-${NETDEV}"
   exec_local_debug cat /etc/sysconfig/network-scripts/ifcfg-${NETDEV}
   return 0
}

function check_cmd_params() {
    while getopts "R" Option
      do
      case $Option in
	  R ) # running non recursive for nfs-mounts
	      non_recursive=1
	      ;;
	  *)
	      ;;
      esac
    done
}

function ip2Config() {
  local ipAddr=$(getPosFromIPString 1, $1)
  local ipGate=$(getPosFromIPString 3, $1)
  local ipNetmask=$(getPosFromIPString 4, $1)
  local ipHostname=$(getPosFromIPString 5, $1)
  local ipDevice=$(getPosFromIPString 6, $1)
  echo_local_debug "ip2Config($ipAddr, $ipGate, $ipNetmask, $ipHostname, $ipDevice)"
  case `getShortRelease` in
      "redhat")
	  echo_local -n "Generating ifcfg for redhat ($ipAddr, $ipGate, $ipNetmask, $ipHostname, $ipDevice)..."
	  exec_local generateRedHatIfCfg "$ipAddr" "$ipGate" "$ipNetmask" "$ipHostname" "$ipDevice"
	  ;;
      "SuSE")
	  echo_local -n "Generating ifcfg for "`getShortRelease`" ($ipAddr, $ipGate, $ipNetmask, $ipHostname, $ipDevice)..."
	  exec_local generateSuSEIfCfg "$ipAddr" "$ipGate" "$ipNetmask" "$ipHostname" "$ipDevice"
	  ;;
      *)
	  echo "ERROR: Generic network-config not supported for distribution: "$(getRelease)
	  return -1
	  ;;
  esac
}

function exec_nondefault_boot_source() {
    local boot_source=$1
    local mount_dir=$2
    local init=$3
    if [ -z "$mount_dir" ]; then mount_dir="/mnt"; fi
    if [ -z "$init" ]; then init=$(getBootParm init); fi
    echo_local "Mounting nfs from \"$boot_source\" to \"$mount_dir\"..."
    exec_local mount -t nfs $boot_source $mount_dir
    
    echo_local "Executing \"$mnt/$init\"..."
    exec_local $mnt/$init
}

function initBootProcess() {
    date=`/bin/date`
    
    echo_local "***********************************"
    echo_local "Starting GFS Shared Root for $HOSTNAME"
    echo_local "Date: $date"
    echo_local "***********************************"
    
    echo_local_debug "*****************************"
    echo_local -n "0.1 Mounting Proc-FS"
    exec_local /bin/mount -t proc proc /proc
    echo_local_debug "*****************************"
    echo_local_debug "0.2 /proc/cmdline"
    exec_local_debug cat /proc/cmdline
    
    # getting all bootparams
    debug=`getBootParm com-debug`
    stepmode=`getBootParm com-step`
    return $?
}

function getNetParameters() {

	echo_local "*********************************"
	echo_local "Scanning for Network parameters"
	echo_local "*********************************"
	ipConfig=`getBootParm ip dhcp`
}

function getBootParameters() {
	echo_local "*********************************"
	echo_local "Scanning for optinal parameters"
	echo_local "*********************************"
	mount_opts=`getBootParm mountopt defaults`
	boot_source=`getBootParm bootsrc default`
	bootpart=`getBootParm bootpart bash`
}

function loadSCSI() {
	if [ -z "${FC_MODULES}"]; then
	    FC_MODULES="scsi_hostadapter"
	fi
	echo_local "3 Loading scsi-driver..."
	
	echo_local -n "3.1 Loading scsi_disk Module..."
	exec_local /sbin/modprobe sd_mod
	
	echo_local -n "3.2 Loading $FC_MODULES"
	exec_local /sbin/modprobe ${FC_MODULES}
	step
	
	echo_local "3.2 Importing unconfigured scsi-devices..."
	devs=$(find /proc/scsi -name "[0-9]*" 2> /dev/null)
#  ids=$(find /proc/scsi -name "[0-9]*" -printf "%f\n" 2>/dev/null)
	channels=0
	for dev in $devs; do 
	    for channel in $channels; do
		id=$(basename $dev)
		echo_local -n "3.2.$dev On id $id and channel $channel"
		add_scsi_device $id $channel $dev
	    done
	done
	echo_local_debug "3.3 Configured SCSI-Devices:"
	exec_local_debug /bin/cat /proc/scsi/scsi
} 

function pivotRoot() {
    echo_local_debug "**********************************************************************"
    [ ! -d /mnt/oldroot ] && mkdir -p /mnt/oldroot
    cd /mnt/newroot
    exec_local /sbin/pivot_root . mnt/oldroot

    echo_local "7. Starting init-process (exec /sbin/init < /dev/console 1>/dev/console 2>&1)..."
    if [ $critical -eq 0 ]; then
		exec /sbin/init < /dev/console 1>/dev/console 2>&1
    else
		/rescue.sh
		exec /bin/bash
    fi
}

function ipaddress_from_name() {
   gfsip=`/bin/nslookup ${name} | /bin/grep -A1 Name: | /bin/grep Address: | /bin/sed -e "s/\\W*Address:\\W*//"`
}
function ipaddress_from_dev() {
   gfsip=`/sbin/ifconfig ${netdev} | /bin/grep "inet addr:" | /bin/sed -e "s/\\W*inet\\Waddr://" | /bin/sed -e "s/\\W*Bcast:.*$//"`
}
function echo_local() {
   echo ${*:0:$#-1} "${*:$#}"
   echo ${*:0:$#-1} "${*:$#}" >> $bootlog
}
function echo_local_debug() {
   if [ ! -z "$debug" ]; then
     echo ${*:0:$#-1} "${*:$#}"
     echo ${*:0:$#-1} "${*:$#}" >> $bootlog
   fi
}

function getDistributionRelease {
   cat /etc/*-release 2>/dev/null
}

function detectHardware() {
    echo_local_debug "*****************************"
    echo_local -n "1. Hardware autodetection"
    case `getRelease` in
	"Red Hat"*)
	    exec_local /usr/sbin/kudzu -t 30 -s -q
	    ;;
	"SuSE"*)
	    suse_hwscan
	    ;;
	*)
	    echo_local "No release set. Old bootimage version."
	    echo_local "Please update to latest Bootimage..."
	    echo_local "Using red hat kudzu..."
	    exec_local /usr/sbin/kudzu -t 30 -s -q
	    ;;
    esac
    ret_c=$?
    echo_local -n "1.1 Module-depency"
    exec_local /sbin/depmod -a
    echo_local_debug "File /etc/modules.conf: ***"
    exec_local_debug cat /etc/modules.conf
    step
    return $ret_c
}

function suse_hwconfig() {
    local name=$1
    local hwinfo_type=$2
    local alias=$3
    local hwinfo=$(hwinfo --$hwinfo_type | grep "Driver Info #0" -A2)
    local index=0
    while [ -n "$hwinfo" ]; do
	lines=$(echo "$hwinfo" | wc -l)
	local cmd=$(echo "$hwinfo" | grep "Driver Activation Cmd" | head -n1 | awk -F ':' '{ match($2, "\"([^\"]+)\"", cmd); print $1, cmd[1];}');
	local module=$(echo "$hwinfo" | grep "Driver Status" | head -n1 | awk -F ':' '{ print $2;}' | awk '{print $1;}');
	echo_local "   suse_hwscan: loading $name ($hwinfo_type/$module)..."
	exec_local modprobe $cmd
    
	if [ -n "$alias" ]; then
	    cp /etc/modules.conf /etc/modules.conf.bak
	    echo_local "   suse_hwscan: registering alias \"$alias\" to module \"$module\"..."
	    cat /etc/modules.conf.bak | awk -v alias="$alias$index" -v module="$module" '
$1 == "alias" && $2 == alias {
   print "alias", alias, module;
   alias_set=1;
   next;
}
{ print; }
END {
  if (!alias_set) {
     print "alias", alias, module;
  }
}
' > /etc/modules.conf
	fi
	let lines="$lines-3"
	hwinfo=$(echo "$hwinfo" | tail -n $lines)
	let index++
    done
}

function suse_hwscan() {
    echo_local "HWSCAN: Detecting scsi-controller: "
    exec_local suse_hwconfig "scsi-controller" "storage-ctrl" "scsi-hostadapter"
    echo_local "HWSCAN: Detecting NIC: "
    exec_local suse_hwconfig "nic" "netcard" "eth"
}

function exec_local() {
  output=`$* 2>&1`
  return_c=$?
  if [ ! -z "$debug" ]; then 
    echo "cmd: $*"
    echo "$output"
  fi
  echo "cmd: $*" >> $bootlog
  echo "$output" >> $bootlog
  return_code $return_c
}

function exec_local_debug() {
  if [ ! -z "$debug" ]; then
    exec_local $*
  fi
}

function return_code() {
  if [ -z "$1" ]; then
    return_c=$?
  else
    return_c=$1
  fi
  if [ $return_c -eq 0 ]; then
     echo_local "(OK)"
  else
     echo_local "(FAILED)"
  fi
}

function add_scsi_device() {
  id=$1
  channel=$2
  dev=$3
  if [ "$(basename $(dirname $dev))" = "qla2200" -o "$(basename $(dirname $dev))" = "qla2300" ]; then
    out=$(cat $dev | awk -v id=$id -v channel=$channel '
/\(([0-9 ]+):([0-9 ]+)\): Total reqs [0-9]+, Pending reqs [0-9]+, flags 0x0.+/ { 
  match($_, /\(\W*([0-9]+):\W*([0-9]+)\)/, res); 
  print "echo \"scsi add-single-device", id, channel, res[1], res[2],  "\" > /proc/scsi/scsi; sleep 1"; 
}')
    eval "$out"
    return $?
  else
    exec_local echo -n ""
    return 0
  fi
}

# $Log: boot-lib.sh,v $
# Revision 1.1  2004-07-31 11:24:43  marc
# initial revision
#