#
# $Id: boot-lib.sh,v 1.25 2006-01-28 15:09:13 marc Exp $
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

step_timeout=5
bootlog="/var/log/comoonics-boot.log"
error_code_file="/var/error_code"
init_cmd_file="/var/init_cmd"
# the disk where the bootlog should be written to (default /dev/fd0).
diskdev="/dev/fd0"
[ -e /usr/bin/logger ] && logger="/usr/bin/logger -t com-bootlog"
modules_conf="/etc/modprobe.conf"

# Default init cmd is bash
init_cmd="/bin/bash"

function exit_linuxrc() {
    error_code=$1
    if [ -n "$2" ]; then 
      init_cmd=$2
    fi
    echo_local_debug "exit_linuxrc($error_code)"
    if [ -z "$error_code" ]; then 
	error_code=0
    fi
    echo $error_code > $error_code_file
    if [ -n "$error_code" ] && [ $error_code -eq 2 ]; then
        echo_local "Userquit falling back to bash.."
	exec 5>&1 6>&2 1>/dev/console 2>/dev/console
        /bin/bash
	exec 1>&5 2>&6
    else
	echo_local "Writing $init_cmd => $init_cmd_file"
	echo "$init_cmd" > $init_cmd_file
	exit $error_code
    fi
}

function step() {
   if [ ! -z "$stepmode" ]; then
     echo_out -n "Press <RETURN> to continue ..."
     read -t$step_timeout __the_step
     [ "$__the_step" = "quit" ] && exit_linuxrc 2
     if [ "$__the_step" = "continue" ]; then
       stepmode=
     fi
   else
     sleep 1
   fi
}
function getBootParm() {
   parm="$1"
   default="$2"
   cmdline=`cat /proc/cmdline`
   out=`expr "$cmdline" : ".*$parm=\([^ ]*\)" 2>/dev/null`
   if [ $(expr "$cmdline" : ".*$parm" 2>/dev/null) -gt 0 ] && [ -z "$out" ]; then out=1; fi
   if [ -z "$out" ]; then out="$default"; fi
   echo "$out"
   if [ -z "$out" ]; then
       return 1
   else
       return 0
   fi
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
   local ipconfig=$2
   echo_local "   Loading module for $dev..."
   exec_local modprobe $dev && sleep 2 && ifconfig $dev up 
   if [ $return_c -eq 0 ] && [ -n "$ipconfig" ] && [ "$ipconfig" != "skip" ]; then
       sleep 2
       echo_local "   Recreating network configuration for $dev"
       exec_local ip2Config $(getPosFromIPString 1, $ipconfig)::$(getPosFromIPString 3, $ipconfig):$(getPosFromIPString 4, $ipconfig):$(hostname):$dev
       echo_local "   Starting network configuration for $dev with config $ipconfig"
       exec_local ifup $dev
       echo_local -n "   Patching /etc/hosts..."
       exec_local patch_hosts
   fi
   return $return_c
}

function patch_hosts {
   ip=$(ifconfig eth0 | grep "inet addr" | awk '{ match($2, ":(.+)$", ip); print ip[1]; }') || return 1
   hostname=$(hostname)
   hostname_f=$(hostname -f)
   echo -e "$ip\t$hostname\t$hostname_f" >> /etc/hosts
}

function ip2Config() {
  if [ $# -eq 1 ]; then
    local ipAddr=$(getPosFromIPString 1, $1)
    local ipGate=$(getPosFromIPString 3, $1)
    local ipNetmask=$(getPosFromIPString 4, $1)
    local ipHostname=$(getPosFromIPString 5, $1)
    local ipDevice=$(getPosFromIPString 6, $1)
  else
    local ipAddr=$1
    local ipGate=$2
    local ipNetmask=$3
    local ipHostname=$4
    local ipDevice=$5
  fi

  echo_local_debug "ip2Config($ipAddr, $ipGate, $ipNetmask, $ipHostname, $ipDevice)"
  case `getShortRelease` in
      "redhat")
	  echo_local -n "Generating ifcfg for redhat ($ipAddr, $ipGate, $ipNetmask, $ipHostname, $ipDevice)..."
	  (generateRedHatIfCfg "$ipDevice" "$ipAddr" "$ipGate" "$ipNetmask" "$ipHostname" &&
	   echo_local "(OK)") || echo_local "(FAILED)"
	  ;;
      "SuSE")
	  echo_local -n "Generating ifcfg for "`getShortRelease`" ($ipAddr, $ipGate, $ipNetmask, $ipHostname, $ipDevice)..."
	  (generateSuSEIfCfg "$ipDevice" "$ipAddr" "$ipGate" "$ipNetmask" "$ipHostname" &&
	  echo_local "(OK)") || echo_local "(FAILED)"
	  ;;
      *)
	  echo "ERROR: Generic network-config not supported for distribution: "$(getRelease)
	  return -1
	  ;;
  esac
}

function getPosFromIPString() {
  pos=$1
  str=$2
  echo $str | awk -v pos=$pos 'BEGIN { FS=":"; }{ print $pos; }'
}

function generateSuSEIfCfg() {
  local ipDevice=$1
  local ipAddr=$2
  local ipGate=$3
  local ipNetmask=$4
  local ipHostname=$5

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

  awk -F'=' bootproto="$bootproto" ipaddr="$ipAddr" netmask="$ipNetmask" startmode="onboot" '
BEGIN {
  for (i=1; i < ARGC; i++) {
    split(ARGV[i], value_pair, "=");
    printf("%s=%s\n", toupper(value_pair[1]), value_pair[2]);
  }
}
'> /etc/sysconfig/network/ifcfg-$ipDevice
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
  local ipDevice=$1
  local ipAddr=$2
  local ipGate=$3
  local ipNetmask=$4
  local ipHostname=$5

  # just for testing
  #local $pref="/tmp"

  if [ -z "$ipHostname" ]; then ipHostname="localhost.localdomain"; fi
  if [ -z "$ipDevice" ]; then ipDevice="eth0"; fi

  # first save
  if [ -e ${__prefix}/etc/sysconfig/network ]; then
    mv ${__prefix}/etc/sysconfig/network ${__prefix}/etc/sysconfig/network.com_back
  fi
  if [ -e ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ]; then
    mv ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice ${__prefix}/etc/sysconfig/network-scripts/ifcfg-${ipDevice}.com_back
  fi
  if [ "$ipAddr" = "dhcp" -o "$ipAddr" = "DHCP" -o -z "$ipAddr" ]; then 
    bootproto="dhcp"
  else 
    bootproto="static"
  fi
  (echo "DEVICE=$ipDevice" && 
   echo "BOOTPROTO=$bootproto" && 
   echo "ONBOOT=no") > ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
  if [ "$bootproto" != "dhcp" ]; then
     (echo "IPADDR=$ipAddr" && 
	 if [ -n "$ipNetmask" ]; then echo "NETMASK=$ipNetmask"; fi) >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     if [ -n "$ipGate" ]; then 
	 echo "GATEWAY=$ipGate" >> ${__prefix}/etc/sysconfig/network-scripts/ifcfg-$ipDevice
     fi
   fi
   (echo "NETWORKING=yes" &&
    echo "HOSTNAME=$ipHostname") > ${__prefix}/etc/sysconfig/network
   if [ $(/bin/hostname) = "(none)" ] || [ $(/bin/hostname) = "localhost.localdomain" ] || [ $(/bin/hostname) = "localhost" ]; then 
       /bin/hostname $ipHostname; 
   fi
   echo_local_debug "   /etc/sysconfig/network"
   exec_local_debug cat /etc/sysconfig/network
   echo_local_debug "   /etc/sysconfig/network-scripts/ifcfg-${ipDevice}"
   exec_local_debug cat /etc/sysconfig/network-scripts/ifcfg-${ipDevice}
   return 0
}

function usage() {
    echo "$0 [-R] [-s|S] [-d|D] [-h]"
    echo -e "\t-R: non recursive for nfs-mounts (experimental or obsolete)"
    echo -e "\t-s|S: set stepmode (s) or unset stepmode (S)"
    echo -e "\t-d|D: set debugmode (d) or unset stepmode (D)"
    echo -e "\t-h:   this usage."
}

function check_cmd_params() {
    while getopts "Rsd" Option
      do
      case $Option in
	  R ) # running non recursive for nfs-mounts
	      non_recursive=1
	      ;;
          s) # stepmode
              stepmode=1
	      ;;
	  d) # debug
	      debug=1
	      ;;
	  h) # help
	      usage
	      exit 0
	      ;;
	  *)
	      echo "Wrong option."
	      usage
	      exit 1
	      ;;
      esac
    done
    return $OPTIND;
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
    echo_local "Scanning for optional parameters"
    echo_local "*********************************"
    echo_local_debug "** /proc/cmdline: "
    exec_local_debug cat /proc/cmdline
    mount_opts=`getBootParm mountopt defaults`
    boot_source=`getBootParm bootsrc default`
    bootpart=`getBootParm bootpart bash`
    tmpfix=$(getBootParm tmpfix)
    iscsi=$(getBootParm iscsi)
    netdevs=$(getBootParm netdevs | tr ":" " ")
    chroot=$(getBootParm chroot)
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

# must be set before lock_gulmd is started.
function setHWClock() {
    # copied from rc.sysinit dependent on /etc/sysconfig/clock should reside in depfile.
    ARC=0
    SRM=0
    UTC=0

    if [ -f /etc/sysconfig/clock ]; then
	. /etc/sysconfig/clock
	
        # convert old style clock config to new values
	if [ "${CLOCKMODE}" = "GMT" ]; then
	    UTC=true
	elif [ "${CLOCKMODE}" = "ARC" ]; then
	    ARC=true
	fi
    fi

    CLOCKDEF=""
    CLOCKFLAGS="$CLOCKFLAGS --hctosys"

    case "$UTC" in
	yes|true)   CLOCKFLAGS="$CLOCKFLAGS --utc"
	    CLOCKDEF="$CLOCKDEF (utc)" ;;
	no|false)   CLOCKFLAGS="$CLOCKFLAGS --localtime"
	    CLOCKDEF="$CLOCKDEF (localtime)" ;;
    esac
    case "$ARC" in
	yes|true)   CLOCKFLAGS="$CLOCKFLAGS --arc"
	    CLOCKDEF="$CLOCKDEF (arc)" ;;
    esac
    case "$SRM" in
	yes|true)   CLOCKFLAGS="$CLOCKFLAGS --srm"
	    CLOCKDEF="$CLOCKDEF (srm)" ;;
    esac
    
    echo_local "Setting clock $CLOCKDEF: "$(date)
    exec_local /sbin/hwclock $CLOCKFLAGS
}

function pivotRoot() {
    echo_local_debug "**********************************************************************"
    echo_local -n "5.4 Pivot-Rooting... (pwd: "$(pwd)")"
    cd /mnt/newroot
    [ ! -d initrd ] && mkdir -p initrd
    /sbin/pivot_root . initrd
    bootlog="/var/log/comoonics-boot.log"
    if [ $? -eq 0 ]; then echo_local "(OK)"; else echo_local "(FAILED)"; fi
    step

    if [ $critical -eq 0 ]; then
	if [ -n "$tmpfix" ]; then 
	    echo_local "6. Setting up tmp..."
	    exec_local createTemp /dev/ram1
	fi

	echo_local "7. Cleaning up..."
	exec_local umount initrd/proc
	mtab=$(cat /etc/mtab 2>&1)
	echo_local_debug "7.1 mtab: $mtab"

	echo_local "7.2 Stopping syslogd..."
        exec_local stop_service "syslogd" /initrd

	init_cmd="/sbin/init"
	echo_local "8. Starting init-process ($init_cmd)..."
	exit_linuxrc 0 $init_cmd
    else
	exit_linuxrc 1
    fi
}

function chRoot() {
    echo_local_debug "**********************************************************************"
    echo_local -n "5.4 Change-Root... (pwd: "$(pwd)"=>/mnt/newroot)"
    cd /mnt/newroot
#    [ ! -d initrd ] && mkdir -p initrd
#    /sbin/pivot_root . initrd
#    bootlog="/var/log/comoonics-boot.log"
    if [ $? -eq 0 ]; then echo_local "(OK)"; else echo_local "(FAILED)"; fi
    step

    if [ $critical -eq 0 ]; then
	if [ -n "$tmpfix" ]; then 
	    echo_local "6. Setting up tmp..."
	    exec_local createTemp /dev/ram1
	fi
	echo_local "7. Cleaning up..."
	exec_local umount /proc
	mtab=$(cat /etc/mtab 2>&1)
	echo_local_debug "7.1 mtab: $mtab"
#	echo_local "7.2 Stopping syslogd..."
#        exec_local stop_service "syslogd" /initrd
	init_cmd="chroot . /sbin/init"
	echo_local "8. Starting init-process ($init_cmd)..."
	exit_linuxrc 0 "$init_cmd"
    else
	exit_linuxrc 1
    fi
}

function switchRoot() {
    echo_local_debug "**********************************************************************"
    cd /mnt/newroot
    pivot_root=initrd
    gfs_restart_cluster_services "../../" ./
    echo_local -n "5.4 Pivot-Rooting... (pwd: "$(pwd)")"
    [ ! -d $pivot_root ] && mkdir -p $pivot_root
    /sbin/pivot_root . $pivot_root
    if [ $? -eq 0 ]; then
      echo_local "(OK)"
    else
      critical=$?
      echo_local "(FAILED)"
    fi
#      mount --move . /
    init_cmd="/sbin/init"
    bootlog="/var/log/comoonics-boot.log"
    step

    #mountDev
    if [ $critical -eq 0 ]; then
	if [ -n "$tmpfix" ]; then 
	    echo_local "6. Setting up tmp..."
	    exec_local createTemp /dev/ram1
	fi

	echo_local "7. Cleaning up..."
	exec_local umount ${pivot_root}/proc
	exec_local umount ${pivot_root}/sys
	
#	mtab=$(cat /etc/mtab 2>&1)
#	echo_local_debug "7.1 mtab: $mtab"

	echo_local "7.2 Stopping syslogd..."
	exec_local stop_service "syslogd" /${pivot_root}
	exec_local killall syslogd

	echo_local "7.3 Removing files in initrd"
	exec_local rm -rf /initrd/*
	step

	echo_local "8. Starting init-process ($init_cmd)..."
	exit_linuxrc 0 "$init_cmd"
    else
	exit_linuxrc 1
    fi
}

function mountDev {
	mount -t proc proc /proc
	mount -t sysfs none /sys
	mount -o mode=0755 -t tmpfs none /dev
	mknod /dev/console c 5 1
	mknod /dev/null c 1 3
	mknod /dev/zero c 1 5
	mkdir /dev/pts
	mkdir /dev/shm
	echo_local "Starting udev"
	/sbin/udevstart
	echo_local "Making device-mapper control node"
	mkdmnod
	#echo_local Scanning logical volumes
	#lvm vgscan
	#echo_local Activating logical volumes
	#lvm vgchange -ay
	echo_local "Making device nodes"
	/sbin/lvm.static vgmknodes
}

function createTemp {
    local device=$1
    mkfs.ext2 -L tmp $device
    mount $device ./tmp
    chmod -R a+t,a+rwX ./tmp/. ./tmp/*
}

function stop_service {
  local service_name=$1
  local other_root=$2
  if [ -f ${other_root}/var/run/${service_name}.pid ]; then
    exec_local kill $(cat ${other_root}/var/run/${service_name}.pid)
  fi
}

function clean_initrd() {
    echo_local_debug "**********************************************************************"
    echo_local "6.2 Cleaning up initrd ."
    echo_local -n "6.2.1 Umounting procfs"
    exec_local /bin/umount /i/proc
    echo_local -n "6.2.2 Umounting /initrd"
    exec_local /bin/umount /mnt/oldroot
    echo_local -n "6.2.3 Freeing memory"
    exec_local /sbin/blockdev --flushbufs /dev/ram0
}

function ipaddress_from_name() {
   gfsip=`/bin/nslookup ${name} | /bin/grep -A1 Name: | /bin/grep Address: | /bin/sed -e "s/\\W*Address:\\W*//"`
}
function ipaddress_from_dev() {
   gfsip=`/sbin/ifconfig ${netdev} | /bin/grep "inet addr:" | /bin/sed -e "s/\\W*inet\\Waddr://" | /bin/sed -e "s/\\W*Bcast:.*$//"`
}
function echo_out() {
    echo ${*:0:$#-1} "${*:$#}" >&3
}

function echo_local() {
   echo ${*:0:$#-1} "${*:$#}"
   echo ${*:0:$#-1} "${*:$#}" >&3
#   echo ${*:0:$#-1} "${*:$#}" >> $bootlog
#   [ -n "$logger" ] && echo ${*:0:$#-1} "${*:$#}" | $logger
}
function echo_local_debug() {
   if [ ! -z "$debug" ]; then
     echo ${*:0:$#-1} "${*:$#}"
     echo ${*:0:$#-1} "${*:$#}" >&3
#     echo ${*:0:$#-1} "${*:$#}" >> $bootlog
#     [ -n "$logger" ] && echo ${*:0:$#-1} "${*:$#}" | $logger
   fi
}
function error_out() {
    echo ${*:0:$#-1} "${*:$#}" >&4
}
function error_local() {
   echo ${*:0:$#-1} "${*:$#}" >&2
   echo ${*:0:$#-1} "${*:$#}" >&4
#   echo ${*:0:$#-1} "${*:$#}" >> $bootlog
#   [ -n "$logger" ] && echo ${*:0:$#-1} "${*:$#}" | $logger
}
function error_local_debug() {
   if [ ! -z "$debug" ]; then
     echo ${*:0:$#-1} "${*:$#}" >&2
     echo ${*:0:$#-1} "${*:$#}" >&4
#     echo ${*:0:$#-1} "${*:$#}" >> $bootlog
#     [ -n "$logger" ] && echo ${*:0:$#-1} "${*:$#}" | $logger
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

function detectHardwareSave() {
    echo_local_debug "*****************************"
    echo_local -n "1. Hardware autodetection"
    case `getRelease` in
	"Red Hat"*)
	    exec_local /usr/sbin/kudzu -t 30 -c SCSI -q 
		mv /etc/modprobe.conf /etc/modprobe.conf.scsi
	    #exec_local /usr/sbin/kudzu -t 30 -c RAID -q 
	    #	mv /etc/modprobe.conf /etc/modprobe.conf.raid
	    exec_local /usr/sbin/kudzu -t 30 -c USB -q 
		mv /etc/modprobe.conf /etc/modprobe.conf.usb
	    exec_local /usr/sbin/kudzu -t 30 -c NETWORK -q
		cat /etc/modprobe.conf.scsi >> /etc/modprobe.conf
	    #	cat /etc/modprobe.conf.raid >> /etc/modprobe.conf
		cat /etc/modprobe.conf.usb >> /etc/modprobe.conf
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
#  echo "cmd: $*" >> $bootlog
#  echo "$output" >> $bootlog
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
# Revision 1.25  2006-01-28 15:09:13  marc
# reenabled fenced restart in initrd and added chroot
# no support for chroot any more
#
# Revision 1.24  2006/01/27 10:54:48  marc
# with mount --move instead of pivot_root
#
# Revision 1.23  2006/01/25 14:49:19  marc
# new i/o redirection
# new switchroot
# bugfixes
# new stepmode
#
# Revision 1.22  2006/01/23 14:11:36  mark
# added mountDev
#
# Revision 1.21  2005/07/08 13:00:34  mark
# added devfs support
#
# Revision 1.19  2005/01/05 10:58:02  marc
# added error_local and error_local_debug
# syslog is only stopped withing pivotroot.
#
# Revision 1.18  2005/01/03 08:29:10  marc
# first offical rpm version
# - added boot-parm to switch between chroot/pivotroot default pivotroot
# - added function to stop a service
# - minor changes
#
# Revision 1.17  2004/09/29 14:32:16  marc
# vacation checkin, stable version
#
# Revision 1.16  2004/09/27 08:07:43  marc
# small update
#
# Revision 1.15  2004/09/27 07:59:07  marc
# again check_boot_params
#
# Revision 1.14  2004/09/27 07:49:48  marc
# rechanged echo_local
#
# Revision 1.13  2004/09/27 07:35:26  marc
# on boot=no
#
# Revision 1.12  2004/09/27 07:29:41  marc
# check_cmd_params and usage
#
# Revision 1.11  2004/09/26 14:56:10  marc
# better ip2Config
#
# Revision 1.10  2004/09/26 14:41:28  marc
# changes to ip2config to generate the proper hostname on redhat.
#
# Revision 1.9  2004/09/26 14:19:38  marc
# small bugfix
#
# Revision 1.8  2004/09/24 14:52:02  marc
# exit from step
#
# Revision 1.7  2004/09/24 08:46:14  marc
# added iscsi as parameter
#
# Revision 1.6  2004/09/13 09:23:32  marc
# fixed the default gw in generateRedHatIfCfg()
#
# Revision 1.5  2004/09/08 16:12:53  marc
# first stable version vor autoconfigure from cca
#
# Revision 1.4  2004/08/23 08:47:19  marc
# first stable release for tmpfix-param.
#
# Revision 1.3  2004/08/13 15:53:46  marc
# added support for chroot
#
# Revision 1.2  2004/08/11 16:53:26  marc
# bugfixes
#
# Revision 1.1  2004/07/31 11:24:43  marc
# initial revision
#
