#!/bin/bash
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
#****h* comoonics-bootimage/linuxrc.generic.sh
#  NAME
#    linuxrc
#    $Id: linuxrc.generic.sh,v 1.113 2011-02-28 09:02:11 marc Exp $
#  DESCRIPTION
#    The first script called by the initrd.
#*******

#****b* comoonics-bootimage/linuxrc/com-stepmode
#  NAME
#    com-stepmode
#  DESCRIPTION
#   If set it asks for <return> after every step
#***** com-step

#****b* comoonics-bootimage/linuxrc/com-debug
#  NAME
#    com-debug
#  DESCRIPTION
#    If set debug info is output
#***** com-debug

#****f* linuxrc.generic.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main()
#  MODIFICATION HISTORY
#  IDEAS
#
#  SOURCE
#
# initstuff is done in here

predir=$(dirname $0)
source ${predir}/etc/std-lib.sh
sourceLibs $predir

export predir
repository_store_value shellrcfile ${predir}/etc/bashrc
repository_store_value shellissue ${predir}/etc/issue
repository_store_value shellissuetmp ${predir}/tmp/issue
repository_store_value shell "/bin/bash --rcfile $(repository_get_value shellrcfile)"
repository_store_value logo "${predir}/$atixlogofile"
repository_store_value sysctlfile "${predir}/etc/sysctl.conf"
repository_store_value xtabfile /etc/xtab
repository_store_value xrootfsfile /etc/xrootfs
repository_store_value xkillallprocsfile /etc/xkillallprocs

if [ $# -gt 1 ]; then
  echo_local -n "Checking commandline parmeters \"$*\""
  check_cmd_params $*
  return_code 0
fi

which python &>/dev/null
if [ $? -eq 0 ]; then
  PYTHONPATH=$(python -c 'import os; import sys; print (os.path.join("/usr", "lib", "python%u.%u" %(int(sys.version[0]), int(sys.version[2])), "site-packages"))')
  export PYTHONPATH
fi

# if supported by distribution start udev here
echo_local -n "Starting udev daemon.."
exec_local udev_daemon_start
return_code $?

echo_local "Starting ATIX initrd"
echo_local "Comoonics-Release"
release=$(cat ${predir}/etc/comoonics-release)
echo_local "$release"
echo_local 'Internal Version $Revision: 1.113 $ $Date: 2011-02-28 09:02:11 $'
echo_local "Builddate: "$(date)

initBootProcess
typeset -f plymouth_setup >/dev/null 2>&1 && plymouth_setup

x=`cat /proc/version`;
KERNEL_VERSION=`expr "$x" : 'Linux version \([^ ]*\)'`
echo_local "Kernel-version: ${KERNEL_VERSION}"
if [ "${KERNEL_VERSION:0:3}" = "2.4" ]; then
  modules_conf="/etc/modules.conf"
else
  modules_conf="/etc/modprobe.conf"
fi

# boot parameters
echo_local -n "Scanning for Bootparameters..."
getParameter newroot "/mnt/newroot" &>/dev/null
getParameter debug $debug &>/dev/null
getParameter step "$stepmode" &>/dev/null
getParameter dstep "$dstepmode" &>/dev/null
getParameter nousb &>/dev/null
return_code 0

# Load USB modules as early as possible so that USB keyboards may be used during the boot process.
if [ -z "$(repository_get_value nousb)" ]; then
  echo_local -n "Loading USB Modules.."
  exec_local usbLoad
  return_code
fi

echo_local_debug "*****************************"
echo_local $"    Press 'I' to enter interactive startup."
echo_local

{
 sleep 5
} &
read -n1 -t5 confirm
if [ "$confirm" = "i" ]; then
  echo_local "    Interactivemode recognized. Switching step_mode to on"
  repository_store_value step
fi
wait

echo_local -n "Validating cluster configuration."
exec_local cc_validate
return_code || breakp $(errormsg err_cc_validate $repository_get_value cluster_conf)
step "Successfully validated cluster configuration" "ccvalidate"

# get number of nodeids and change float to int
nodes=$(cc_get nodes 2>/dev/null | sed -e 's/\.[0-9]*$//')
nodes=${nodes:-0}
#nodeid must be first
nodeid=$(getParameter nodeid $(cc_getdefaults nodeid))
# No need for hwdetection if either nodeid is set or nodes==1 or simulation mode is enabled
if [ -z "$nodeid" ] || ([ "$nodes" -ne 0 ] && [ "$nodes" -gt 1 ]) && ([ -z "$simulation" ] || [ "$simulation" -ne 1 ]) ; then
  num_names=$(cc_get_nic_names | wc -w)
  num_drivers=$(cc_get_nic_drivers | wc -w)
  drivers=""
  if [ $num_drivers -ge $num_names ]; then
  	drivers=$(cc_get_nic_drivers)
  fi
  hardware_detect $drivers
  unset num_names num_drivers drivers

  echo_local -n "Starting network configuration for lo0"
  exec_local nicUp lo
  return_code
fi
step "Hardwaredetection finished" "hwdetect"

# redetect nodeid because hwdata is available now. Will return the previously detected nodeid if present.
nodeid=$(getParameter nodeid $(cc_getdefaults nodeid))
echo_local -n "Detecting nodeid & nodename "
if [ -z "$nodeid" ] && [ -n "$nodes" ] && [ "$nodes" == "1" ]; then
	# if no nodeid found until now and nodes are only 1 either get nodeid from cmdline or set to 1.
	nodeid=$(getParameter nodeid $(cc_get nodeids 2>/dev/null | cut -f1 -d" "))
fi
[ -z "$nodeid" ] && breakp "$(errormsg err_cc_nodeid)"
nodename=$(getParameter nodename $(cc_getdefaults nodename))
#[ -z "$nodename" ] && breakp "$(errormsg err_cc_nodename)"
[ -z "$nodeid" ] && nodeid=$(repository_get_value nodeid)
[ -z "$nodename" ] && nodename=$(repository_get_value nodename)
echo_local -N -n "nodeid: $nodeid, nodename: $nodename "

sourceRootfsLibs ${predir}
success

# Just load nic drivers
_ipConfig=$(cluster_ip_config "$(repository_get_value nodeid)")
[ -n "$_ipConfig" ] && ( [ -z "$(repository_get_value ipConfig)" ] || [ "$(repository_get_value ipConfig)" = "cluster" ] ) && repository_store_value ipConfig "$_ipConfig"

echo_local -n "Scanning other parameters "
_ccparameters=$(cc_get_valid_params)
_fsparameters=$(clusterfs_get_valid_params)
echo_local_debug -N -n "cc: $_ccparameters fs: $_fsparameters "

for _parameter in $_ccparameters; do
  getParameter $_parameter $(cc_getdefaults $_parameter) &>/dev/null
done 

for _parameter in $_fsparameters; do
  getParameter $_parameter $(clusterfs_getdefaults $_parameter) &>/dev/null
done 
if ! $(repository_has_key root); then
	repository_store_value root $(repository_get_value rootvolume)
fi
getParameter ro &>/dev/null
getParameter rw &>/dev/null
if [ -n "$(repository_get_value ro)" ]; then
  if [ -z "$(getPosFromList ro $(repository_get_value mountopts) ,)" ]; then
    if [ -z $(repository_get_value mountopts) ]; then
      repository_store_value mountopts "ro"
    else
      repository_append_value mountopts ",ro"
    fi
  fi
elif [ -n "$(repository_get_value rw)" ]; then
  if [ -z "$(getPosFromList rw $(repository_get_value mountopts) ,)" ]; then
    if [ -z $(repository_get_value mountopts) ]; then
      repository_store_value mountopts "rw"
    else
      repository_append_value mountopts ",rw"
    fi
  fi
fi
success

clusterfs_chroot_needed initrd
__default=$?
getParameter chrootneeded $__default &>/dev/null
[ "$(repository_get_value chrootneeded)" = "__set__" ] && repository_store_value chrootneeded 0 

step "Inialization started" "init"

echo_local_debug "*****<REPOSITORY>***************"
exec_local_debug repository_list_items ":"
echo_local_debug "*****<REPOSITORY>**********"

step "Parameter loaded" "parameter"

# Not needed cause an empty network configuration is also possible
#FIXME: Perhaps we should have something like a function clusterfs_network_needed as a first try.
#if [ -z "$(repository_get_value ipConfig)" ]; then
#  breakp "$(errormsg err_nic_config)"
#fi

xen_domx_detect
if [ $? -ne 0 ] && [ -z "$(repository_get_value nousb)" ]; then
  echo_local -n "Loading USB Modules.."
  exec_local usbLoad
  return_code
  [ -e /proc/bus/usb/devices ] && stabilized --type=hash --interval=300 /proc/bus/usb/devices
fi

if [ -f "$(repository_get_value sysctlfile)" ]; then
  sysctl_load $(repository_get_value sysctlfile)
fi

netdevs=""
for ipconfig in $(repository_get_value ipConfig); do
  dev=$(getPosFromIPString 6, $ipconfig)

  # Special case for bonding
  { echo "$dev"| grep "^bond" && grep -v "alias $dev" $modules_conf; } >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    # Think about bonding parameters.
    # Multi load of bonding driver possible?
    echo_local -n "Patching $modules_conf for bonding "
    echo "alias $dev bonding" >> $modules_conf
    return_code $?
    depmod -a >/dev/null 2>&1
  fi
done

bridgeipconfig=""
vlanipconfig=""
networkipconfig=""
restartipconfig=""
_ipconfig=""
__ipconfig=""
for ipconfig in $(repository_get_value ipConfig); do
  dev=$(getPosFromIPString 6, $ipconfig)
  if [ -z "$dev" ]; then
  	# If only the device is given as ipconfig parameter we suppose there is already
    # a configuration existant in /etc/sysconfig/network-scripts
  	dev=$ipconfig
    networkipconfig="$networkipconfig $dev"
  else
    hwids=$(repository_get_value hardwareids)
    echo_local -n "Creating network configuration for $dev"
    __ipconfig=$(nicConfig $ipconfig "$hwids")
    _type=$(getPosFromIPString 8, $ipconfig)
    _bridge=$(getPosFromIPString 9, $ipconfig)
    if [ "$_type" = "bridge" ]; then
      bridgeipconfig="$bridgeipconfig $__ipconfig"
    elif [[ "$dev" =~ "[a-z]+[0-9]+\.[0-9]+" ]]; then
      vlanipconfig="$vlanipconfig $__ipconfig"
    elif [[ "$dev" =~ "^bond" ]]; then
      bondipconfig="$bondipconfig $__ipconfig" 
      networkipconfig="$networkipconfig $__ipconfig"
    else
      networkipconfig="$networkipconfig $__ipconfig"
    fi
  fi
  if [ $? -ne 0 ]; then
	breakp $(err_nic_config)
  fi
  if [ -n "$_bridge" ]; then
    restartipconfig="$restartipconfig $__ipconfig"
  fi
  _ipconfig="$_ipconfig "$__ipconfig
  return_code $?
done
unset _type
unset __ipconfig
#echo_local_debug "network: $networkipconfig, vlan: $vlanipconfig, bridge: $bridgeipconfig"
repository_store_value ipConfig "$_ipconfig"
step "Network configuration finished" "netconfig"

for ipconfig in $networkipconfig $vlanipconfig $bridgeipconfig $restartipconfig; do
  dev=$(getPosFromIPString 6, $ipconfig)
   driver=$(getPosFromIPString 11, $ipconfig)
  nicAutoUp $ipconfig
  if [ $? -eq 0 ] || [ -z "$dev" ]; then
  	[ -z "$dev" ] && dev=$ipconfig
  	if [ -n "$driver" ]; then
  		echo_local -n "Loading driver $driver for nic $dev.."
  		exec_local modprobe $driver
  		return_code $?
  	elif [ ! -d /sys/class/net/${dev} ]; then
  	    # trigger harware detection if nic is not available
        udev_start
  	fi
    echo_local -n "Powering up $dev.."
    exec_local nicUp $dev boot >/dev/null 2>&1 || breakp "$(errormsg err_nic_ifup $dev)"
    return_code $?
  fi
  netdevs="$netdevs $dev"
done
step "Network started" "netstart"

cc_auto_syslogconfig "$(repository_get_value nodeid)" / "no" "$(repository_get_value syslog_logfile)"
is_syslog=$?
if [ $is_syslog -eq 0 ]; then
  cc_syslog_start
  step "Syslog started." "syslog"
fi

if clusterfs_blkstorage_needed $(repository_get_value rootfs); then
  dm_start $(repository_get_value scsi_failover)
  scsi_start "$(repository_get_value scsi_failover)" "$(repository_get_value rootsource)" $(repository_get_value scsi_driver)
  [ -e /proc/scsi/scsi ]  && stabilized --type=hash --interval=600 /proc/scsi/scsi
  if [ "$(repository_get_value scsi_failover)" = "mapper" ] || [ "$(repository_get_value scsi_failover)" = "devicemapper" ]; then
    dm_mp_start
  fi
  
  md_start
  
  validate_storage || breakp "$(errormsg err_storage_config)"
  step "Storage environment started" "storage"

  lvm_check $(repository_get_value root)
  lvm_sup=$?
  repository_store_value lvm_sup $lvm_sup
  if [ "$lvm_sup" -eq 0 ]; then
	lvm_start $(repository_get_value root) || breakp "$(errormsg err_storage_lvm)"
	step "LVM subsystem started" "lvm"
  fi
fi

# loads kernel modules for cluster stack
# TODO: - rename to clusterfs_kernel_load
#       - add cluster_kernel_load
#       - move below ?
# 1.3.+ ?
clusterfs_load $(repository_get_value lockmethod)
return_code
step "Cluster, modules loaded" "clusterload"

cc_auto_hosts

if [ $(repository_get_value chrootneeded) -eq 0 ]; then
  echo_local -n "Building comoonics chroot environment"
  res=( $(build_chroot $(repository_get_value nodeid)) )
  repository_store_value chroot_mount ${res[0]}
  repository_store_value chroot_path ${res[1]}
  return_code $?
  echo_local_debug "res: $res -> chroot_mount="$(repository_get_value chroot_mount)", chroot_path="$(repository_get_value chroot_path)
  step "chroot environment created" "chroot"
fi

# but only if /dev is not the same inode as $chroot_path /dev
if [ $is_syslog -eq 0 ] && ! is_same_inode /dev $(repository_get_value chroot_path)/dev; then
  cc_auto_syslogconfig $(repository_get_value nodeid) $(repository_get_value chroot_path) "no" $(repository_get_value syslog_logfile)
  cc_syslog_start $(repository_get_value chroot_path) no_klog
  step "Syslog services started in chroot $(repository_get_value chroot_path)" "syslogchroot"
fi

# WARNING!
# DRBD initialization doesn't seem possible before this point!
# start drbd if appropriate
typeset -f isDRBDRootsource >/dev/null 2>&1 && isDRBDRootsource $(repository_get_value rootsource)
if [ $? -eq 0 ]; then
	loadDRBD
	startDRBD $(repository_get_value rootsource) $(repository_get_value nodename)
fi

# or nodes more then one
if [ -z "$(repository_get_value quorumack)" ]; then
  echo_local -n "Checking for all nodes to be available"
  exec_local cluster_checkhosts_alive
  return_code
  if [ $return_c -ne 0 ]; then
  	echo_local ""
  	echo_local ""
  	echo_local "I couldn't talk to the required number of cluster nodes."
	echo_local "To avoid data inconsitency caused by cluster partitioning (split brain) "
	echo_local "the next step has to be acknowledged manually."
	echo_local ""
	echo_local "If you are sure, that the cluster is in a consistent state, please type YES."
	echo_local ""
	echo_local ""
	echo_local "CAUTION: !!! If you are unsure about all other nodes state, check first."
	echo_local "         Otherwise you'll risk split brain with data inconsistency !!!"

	confirm="XXX"
	until [ "$confirm" = "YES" ] || [ "$confirm" = "NO" ]; do
  		echo_local "USER INPUT: (YES|NO): "
  		read confirm
  		echo_local_debug "confirm: $confirm"
  		if [ "$confirm" = "NO" ]; then
  			breakp "Cluster not acknowledged. Falling back to shell"
  		fi
  	done
  fi
fi

# This function starts all services that have to be started prior to mounting the rootfs
# If need be they should be started in the chroot_path.
clusterfs_services_start $(repository_get_value chroot_path) "$(repository_get_value lockmethod)" "$(repository_get_value lvm_sup)"
if [ $return_c -ne 0 ]; then
  breakp "$(errormsg err_cc_setup)"
fi
step "Cluster services started" "clusterstart"
# sleep 5

if repository_has_key rootfsck || clusterfs_fsck_needed $(repository_get_value root) $(repository_get_value rootfs); then
	clusterfs_fsck $(repository_get_value root) $(repository_get_value rootfs)
	if [ $? -ne 0 ]; then
		errormsgissue err_clusterfs_fsck $(repository_get_value root) $(repository_get_value rootfs)
		breakp "Please try to check the rootfilesystem on $(repository_get_value root) manually." 
	fi
fi 

clusterfs_mount "$(repository_get_value rootfs)" "$(repository_get_value root)" "$(repository_get_value newroot)" "$(repository_get_value mountopts)" "$(repository_get_value mounttimes)" "$(repository_get_value mountwait)"
if [ $return_c -ne 0 ]; then
   breakp "$(errormsg err_rootfs_mount)"
fi
step "RootFS mounted return_c ${return_c}" "rootfsmount"

if [ "$(repository_get_value cdsl_local_dir)" != "nocdsl" ] && [ "$(repository_get_value cdsl_prefix)" != "nocdsl" ]; then
  clusterfs_mount_cdsl "$(repository_get_value newroot)" "$(repository_get_value cdsl_local_dir)" "$(repository_get_value nodeid)" "$(repository_get_value cdsl_prefix)"
  if [ $return_c -ne 0 ]; then
	breakp "$(errormsg err_rootfs_mount_cdsl $(repository_get_value root))"
  fi
else
  echo_local_debug "Skipped mounting of cdsl."
fi
step "CDSL tree mounted" "cdsl"

#if [ -n "$debug" ]; then set -x; fi
#TODO clean up method
#copy_relevant_files $cdsl_local_dir $newroot $netdevs
#if [ -n "$debug" ]; then set +x; fi

# FIXME: Remove line
#bootlog="/var/log/comoonics-boot.log"

cdsltabfile=$(repository_get_value cdsltabfile /etc/cdsltab)
filesystems=$(cc_get filesystem_dest $(repository_get_value nodeid))
if [ $? -eq 0 ] && [ -n "$filesystems" ]; then
  for dest in $filesystems; do
    fstype=$(cc_get filesystem_dest_fstype $(repository_get_value nodeid) $dest)
    source=$(cc_get filesystem_dest_source $(repository_get_value nodeid) $dest)
    [ "$fstype" = "bind" ] && source=$(repository_get_value newroot)/$source
    [ "$fstype" = "rbind" ] && source=$(repository_get_value newroot)/$source
        mountopts=$(cc_get filesystem_dest_mountopts $(repository_get_value nodeid) $dest)
    mountwait=$(cc_get filesystem_dest_mountwait $(repository_get_value nodeid) $dest)
    mounttimes=$(cc_get filesystem_dest_mounttimes $(repository_get_value nodeid) $dest)
    dest=$(repository_get_value newroot)/$(cc_get filesystem_dest_dest $(repository_get_value nodeid) $dest)
    [ -z "$mountwait" ] && mountwait="$(repository_get_value mountwait)"
    [ -z "$mounttimes" ] && mountwait="$(repository_get_value mounttimes)"
    if lvm_check $source; then
       vg=$(lvm_get_vg $source)
       echo_local -n "Activating vg $vg"
       dm_start &>/dev/null
       exec_local lvm vgchange -ay $vg
       return_code
    fi
    if repository_has_key fsck || clusterfs_fsck_needed $source $fstype; then
	    clusterfs_fsck $source $fstype
	    if [ $? -ne 0 ]; then
		  errormsgissue err_clusterfs_fsck $source $fstype
		  breakp "Please try to check the filesystem on $source manually." 
	    fi
    fi 
    clusterfs_mount "$fstype" "$source" "$dest" "$mountopts" "$mounttimes" "$mountwait" 
    if [ $return_c -ne 0 ]; then
      breakp "$(errormsg err_clusterfs_mount)"
    fi
  done
  step "Additional filesystems $filesystems mounted." "fsmount"
elif [ -n "$cdsltabfile" ] && [ -f "$cdsltabfile" ]; then
  cat $cdsltabfile | parse_cdsltab "only_initrd_mountpoints" "$(repository_get_value newroot)"
  step "Additional filesystems $filesystems mounted." "fsmount"
fi

typeset -f plymouth_start >/dev/null 2>&1 && plymouth_start $(repository_get_value newroot)
if typeset -f selinux_load_policy >/dev/null 2>&1; then
	 selinux_load_policy $(repository_get_value newroot) ||	breakp "$(errormsg_stdin <<EOF
Could not setup selinux policy.
Please check and decide if you want to continue booting or not. 
EOF)"
fi
step "SElinux and plymouth newroot started." "selinux"

if [ $(repository_get_value chrootneeded) -eq 0 ]; then
  echo_local -n "Moving chroot environment $(repository_get_value chroot_path) to $(repository_get_value newroot)"
  move_chroot $(repository_get_value chroot_mount) $(repository_get_value newroot)/$(repository_get_value chroot_mount)
  return_code

  echo_local -n "Writing information ..."
  exec_local mkdir -p $(repository_get_value newroot)/var/comoonics
  echo $(repository_get_value chroot_path) > $(repository_get_value newroot)/var/comoonics/chrootpath 2>/dev/null
  return_code
  step "Moving chroot successfully done." "movechroot"
else
  if [ -f $(repository_get_value newroot)/var/comoonics/chrootpath ] && [ -z "$(getPosFromList ro $(repository_get_value mountopts) ,)" ]; then
    echo_local -n "Removing reference to chrootpath."
    exec_local rm -f $(repository_get_value newroot)/var/comoonics/chrootpath 2>/dev/null
    return_code
  fi
fi
  
echo_local -n "Writing information to /dev/.initramfs ..."
[ -d /dev/.initramfs ] || mkdir /dev/.initramfs
for parameter in cluster_conf nodeid nodename nodeids chroot_path chrootneeded rootfs; do
  repository_get_value $parameter > /dev/.initramfs/comoonics.$parameter
done
return_code

if [ -z "$(getPosInList ro $(repository_get_value mountopts) ,)" ]; then
  echo_local -n "Writing xtab.. "
  if [ $(repository_get_value chrootneeded) -eq 0 ]; then
    create_xtab "$(repository_get_value newroot)/$(repository_get_value xtabfile)" "/$(repository_get_value cdsl_local_dir)" "$(repository_get_value chroot_mount)" "/var/run" 
  else  
    create_xtab "$(repository_get_value newroot)/$(repository_get_value xtabfile)" "/$(repository_get_value cdsl_local_dir)" "/var/run"
  fi
  success

  echo_local -n "Writing xrootfs.. "
  create_xrootfs $(repository_get_value newroot)/$(repository_get_value xrootfsfile) $(repository_get_value rootfs)
  success

  echo_local -n "Writing xkillall_procs.. "
  create_xkillall_procs "$(repository_get_value newroot)/$(repository_get_value xkillallprocsfile)" "$(repository_get_value clutype)" "$(repository_get_value rootfs)"
  success
  step "Created xtab,xrootfs,xkillall_procs file" "xfiles"
fi

echo_local -n "Mounting the device file system"
#TODO
# try an exec_local mount --move /dev $newroot/dev
exec_local move_dev $(repository_get_value newroot)
#exec_local mount --bind /dev $newroot/dev
return_code

# do something only on rw mounted filesystems
if [ -z $(getPosInList "ro" "$(repository_get_value mountopts)" ",") ]; then
  for logfile_name in bootlog syslog_logfile; do
    logfile=$(repository_get_value $logfile_name)
    if [ -n "$logfile" ] && [ -e "$logfile" ]; then
      echo_local -n "Copying logfile to \"$logfile\"..."
      exec_local cp -f ${logfile} $(repository_get_value newroot)/${logfile} || cp -f ${logfile} $(repository_get_value newroot)/$(basename $logfile)
      return_code
    fi
  done
fi
step "Logfiles copied" "logfiles"
	 
echo_local -n "Cleaning up initrd ..."
exec_local clean_initrd
success
echo_local
step "Cleaned up initrd" "cleanup"

#TODO umount $newroot/proc again

echo_local "Restart services in newroot ..."

exec_local prepare_newroot $(repository_get_value newroot)
step "Prepare newroot" "preparenewroot"

exec_local scsi_restart_newroot "$(repository_get_value scsi_failover)" "$(repository_get_value rootsource)" "$(repository_get_value newroot)" "$(repository_get_value chroot_path)"
step "Scsi restarted in newroot" "scsirestart"

exec_local clusterfs_services_restart_newroot $(repository_get_value newroot) "$(repository_get_value lockmethod)" "$(repository_get_value lvm_sup)" "$(repository_get_value chroot_path)" || breakp "$(errormsg err_cc_restart_service $(repository_get_value clutype))"
step "Cluster services restarted in newroot" "clusterrestart"

if [ $is_syslog -eq 0 ]; then
  #TODO: remove lines as syslog can will stay in /comoonics
  if killall -0 klogd 2>/dev/null; then
    echo_local -n "Stopping klogd..."
    exec_local killall "klogd"
    return_code
  fi
  echo_local -n "Stopping "$(repository_get_value syslogtype)"..."
  exec_local stop_service $(repository_get_value syslogtype) /
  return_code
  if [ $is_syslog -eq 0 ] && ! is_same_inode "/dev" "$(repository_get_value newroot)/$(repository_get_value chroot_path)/dev"; then
  	echo_local -n "Stopping "$(repository_get_value syslogtype)" in "$(repository_get_value newroot)"/"$(repository_get_value chroot_path)"..."
  	exec_local stop_service $(repository_get_value syslogtype) $(repository_get_value newroot)"/"$(repository_get_value chroot_path)
  	sleep 1  # "Wait" for rsyslogd to be stopped 
	return_code
  fi
fi
chrootneeded=$(repository_get_value chrootneeded)
# Resetup syslog to forward messages to the localhost (whatever it does with those messages) but only if chroot is needed.
if [ $chrootneeded -eq 0 ]; then
  cc_auto_syslogconfig "" "" "$(repository_get_value newroot)/$(repository_get_value chroot_path)" "no" "localhost" "no_klog"
  cc_syslog_start "$(repository_get_value newroot)/$(repository_get_value chroot_path)" no_klog
fi
step "Restarted syslogd" "syslogrestart"

chrootpath=$(repository_get_value newroot)/$(repository_get_value chroot_path)
if [ -z $(getPosInList "ro" "$(repository_get_value mountopts)" ",") ]; then
  for logfile_name in bootlog syslog_logfile; do
    if [ -n "$chrootpath/$logfile" ] && [ -e "$chrootpath/$logfile" ]; then
      echo_local -n "Copying logfile to \"$chrootpath/$logfile\"..."
      exec_local cp -f $chrootpath/${logfile} $(repository_get_value newroot)/${logfile}-chroot || cp -f $chrootpath/${logfile} $(repository_get_value newroot)/$(basename $logfile)-chroot
      return_code
    fi
  done
fi
unset chrootpath
step "Logfiles chroot copied" "logfiles"

echo_local "Setting postsettings in initrd.."
exec_local initrd_exit_postsettings / $(repository_get_value newroot)
step "Exit initrd postsettings done" "postsettings"

step "Initialization completed." "initcomplete"

newroot=$(repository_get_value newroot)
echo_local "Starting init-process ($init_cmd)..."
exit_linuxrc 0 "$init_cmd" "$newroot" "$chrootneeded"

#********** main
