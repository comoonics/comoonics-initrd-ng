#!/bin/bash
#
# $Id: linuxrc.generic.sh,v 1.98 2010-07-08 08:15:48 marc Exp $
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

#
#****h* comoonics-bootimage/linuxrc.generic.sh
#  NAME
#    linuxrc
#    $Id: linuxrc.generic.sh,v 1.98 2010-07-08 08:15:48 marc Exp $
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

echo_local "Starting ATIX initrd"
echo_local "Comoonics-Release"
release=$(cat ${predir}/etc/comoonics-release)
echo_local "$release"
echo_local 'Internal Version $Revision: 1.98 $ $Date: 2010-07-08 08:15:48 $'
echo_local "Builddate: "$(date)

initBootProcess
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
getParameter cluster_conf $cluster_conf &>/dev/null
getParameter debug $debug &>/dev/null
getParameter step $stepmode &>/dev/null
getParameter dstep $dstepmode &>/dev/null
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
return_code || breakp $(errormsg err_cc_validate $cluster_conf)
step "Successfully validated cluster configuration" "ccvalidate"

if [ -z "$simulation" ] || [ "$simulation" -ne 1 ]; then
  num_names=$(cc_get_nic_names "" "" "" $(repository_get_value cluster_conf) | wc -w)
  num_drivers=$(cc_get_nic_drivers "" "" "" $(repository_get_value cluster_conf) | wc -w)
  drivers=""
  if [ $num_drivers -ge $num_names ]; then
  	drivers=$(cc_get_nic_drivers "" "" "" $(repository_get_value cluster_conf))
  fi
  hardware_detect $drivers
  unset num_names num_drivers drivers

  echo_local -n "Starting network configuration for lo0"
  exec_local nicUp lo
  return_code
fi
step "Hardwaredetection finished" "hwdetect"

echo_local -n "Detecting nodeid & nodename "

#nodeid must be first
nodeid=$(getParameter nodeid $(cc_getdefaults nodeid))
[ -z "$nodeid" ] && breakp "$(errormsg err_cc_nodeid)"
nodename=$(getParameter nodename $(cc_getdefaults nodename))
[ -z "$nodename" ] && breakp "$(errormsg err_cc_nodename)"
[ -z "$nodeid" ] && nodeid=$(repository_get_value nodeid)
[ -z "$nodename" ] && nodeid=$(repository_get_value nodename)
echo_local -N -n "nodeid: $nodeid, nodename: $nodename "

sourceRootfsLibs ${predir}
success

# Just load nic drivers
auto_netconfig $(cc_get_nic_drivers $(repository_get_value nodeid) $(repository_get_value nodename) "" $(repository_get_value cluster_conf))
found_nics && udev_start # now we should be able to trigger this.
found_nics && breakp "$(errormsg err_hw_nicdriver)"
step "NIC modules loaded." "autonetconfig"

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

_ipConfig=$(cluster_ip_config "$(repository_get_value cluster_conf)" "$(repository_get_value nodename)" "" "$(repository_get_value nodeid)")
[ -n "$_ipConfig" ] && ( [ -z "$(repository_get_value ipConfig)" ] || [ "$(repository_get_value ipConfig)" = "cluster" ] ) && repository_store_value ipConfig "$_ipConfig"

step "Inialization started" "init"

echo_local_debug "*****<REPOSITORY>***************"
exec_local_debug repository_list_items ":"
echo_local_debug "*****<REPOSITORY>**********"

step "Parameter loaded" "parameter"

if [ -z "$(repository_get_value ipConfig)" ]; then
  breakp "$(errormsg err_nic_config)"
fi

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
  if [ $? -eq 0 ]; then
  	if [ -n "$driver" ]; then
  		echo_local -n "Loading driver $driver for nic $dev.."
  		exec_local modprobe $driver
  		return_code $?
  	fi
    echo_local -n "Powering up $dev.."
    exec_local nicUp $dev boot >/dev/null 2>&1 || breakp "$(errormsg err_nic_ifup $dev)"
    return_code $?
  fi
  netdevs="$netdevs $dev"
done
step "Network started" "netstart"

bridges=$(cc_auto_getbridges $(repository_get_value cluster_conf) $(repository_get_value nodename))
if [ -n $bridges ]; then
  for bridge in $bridges; do
     echo_local -n "Setting up network bridge $bridge"
     network_setup_bridge $bridge $(repository_get_value nodename) $(repository_get_value cluster_conf)
     return_code $?
  done
  step "Network bridges setup finished" "netbridge"
fi

cc_auto_syslogconfig $(repository_get_value cluster_conf) $(repository_get_value nodename) / "no" $(repository_get_value syslog_logfile)
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

cc_auto_hosts $(repository_get_value cluster_conf)

if [ $(repository_get_value chrootneeded) -eq 0 ]; then
  echo_local -n "Building comoonics chroot environment"
  res=( $(build_chroot $(repository_get_value cluster_conf) $(repository_get_value nodename)) )
  repository_store_value chroot_mount ${res[0]}
  repository_store_value chroot_path ${res[1]}
  return_code $?
  echo_local_debug "res: $res -> chroot_mount="$(repository_get_value chroot_mount)", chroot_path="$(repository_get_value chroot_path)
  step "chroot environment created" "chroot"
fi

# but only if /dev is not the same inode as $chroot_path /dev
if [ $is_syslog -eq 0 ] && ! is_same_inode /dev $(repository_get_value chroot_path)/dev; then
  cc_auto_syslogconfig $(repository_get_value cluster_conf) $(repository_get_value nodename) $(repository_get_value chroot_path) "no" $(repository_get_value syslog_logfile)
  cc_syslog_start $(repository_get_value chroot_path)
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

xen_domx_detect
if  [ $? -ne 0 ]; then
  setHWClock
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

#FIXME: should somehow detect if we are a cluster if not don't mount cdsl
clusterfs_mount_cdsl "$(repository_get_value newroot)" "$(repository_get_value cdsl_local_dir)" "$(repository_get_value nodeid)" "$(repository_get_value cdsl_prefix)"
if [ $return_c -ne 0 ]; then
	breakp "$(errormsg err_rootfs_mount_cdsl $(repository_get_value root))"
fi
step "CDSL tree mounted" "cdsl"

#if [ -n "$debug" ]; then set -x; fi
#TODO clean up method
#copy_relevant_files $cdsl_local_dir $newroot $netdevs
#if [ -n "$debug" ]; then set +x; fi

# do something only on rw mounted filesystems
if [ -z $(getPosFromList "ro" "$(repository_get_value mountopts)" ",") ]; then
  for logfile_name in bootlog syslog_logfile; do
    logfile=$(repository_get_value $logfile_name)
    if [ -n "$logfile" ] && [ -e "$logfile" ]; then
      echo_local -n "Copying logfile to \"$logfile\"..."
      exec_local cp -f ${logfile} $(repository_get_value newroot)/${logfile} || cp -f ${logfile} $(repository_get_value newroot)/$(basename $logfile)
      if [ -f $(repository_get_value newroot)/$logfile ]; then
        repository_store_value logfile_name $(repository_get_value newroot)/$logfile
      else
        repository_store_value logfile_name $(repository_get_value newroot)/$(basename $logfile)
      fi
    fi
  done
  return_code_warning
fi
#exec 3>> $bootlog
#exec 4>> $bootlog
step "Logfiles copied" "logfiles"

# FIXME: Remove line
#bootlog="/var/log/comoonics-boot.log"

filesystems=$(cc_get $(repository_get_value cluster_conf) filesystem_dest $(repository_get_value nodeid))
if [ $? -eq 0 ] && [ -n "$filesystems" ]; then
  for dest in $filesystems; do
    fstype=$(cc_get $(repository_get_value cluster_conf) filesystem_dest_fstype $(repository_get_value nodeid) $dest)
    source=$(cc_get $(repository_get_value cluster_conf) filesystem_dest_source $(repository_get_value nodeid) $dest)
    [ "$fstype" = "bind" ] && source=$(repository_get_value newroot)/$source
    mountopts=$(cc_get $(repository_get_value cluster_conf) filesystem_dest_mountopts $(repository_get_value nodeid) $dest)
    mountwait=$(cc_get $(repository_get_value cluster_conf) filesystem_dest_mountwait $(repository_get_value nodeid) $dest)
    mounttimes=$(cc_get $(repository_get_value cluster_conf) filesystem_dest_mounttimes $(repository_get_value nodeid) $dest)
    dest=$(repository_get_value newroot)/$(cc_get $(repository_get_value cluster_conf) filesystem_dest_dest $(repository_get_value nodeid) $dest)
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
  done
  step "Additional filesystems $filesystems mounted." "fsmount"
fi

if [ $(repository_get_value chrootneeded) -eq 0 ]; then
  echo_local -n "Moving chroot environment $(repository_get_value chroot_path) to $(repository_get_value newroot)"
  move_chroot $(repository_get_value chroot_mount) $(repository_get_value newroot)/$(repository_get_value chroot_mount)
  return_code

  echo_local -n "Writing information ..."
  exec_local mkdir -p $(repository_get_value newroot)/var/comoonics
  echo $(repository_get_value chroot_path) > $(repository_get_value newroot)/var/comoonics/chrootpath
  return_code
  step "Moving chroot successfully done." "movechroot"
else
  if [ -f $(repository_get_value newroot)/var/comoonics/chrootpath ] && [ -z $(getPosFromList "ro" "$(repository_get_value mountopts)" ",") ]; then
    echo_local -n "Removing reference to chrootpath."
    exec_local rm -f $(repository_get_value newroot)/var/comoonics/chrootpath 2>/dev/null
    return_code
  fi
fi

if [ -z $(getPosInList "ro" "$(repository_get_value mountopts)" ",") ]; then
  echo_local -n "Writing xtab.. "
  if [ $(repository_get_value chrootneeded) -eq 0 ]; then
    create_xtab "$(repository_get_value newroot)/$(repository_get_value xtabfile)" "$(repository_get_value cdsl_local_dir)" "$(repository_get_value chroot_mount)" 
  else  
    create_xtab "$(repository_get_value newroot)/$(repository_get_value xtabfile)" "$(repository_get_value cdsl_local_dir)"
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
	return_code
  fi
  step "Stopped syslogd" "syslogstop"
fi

step "Initialization completed." "initcomplete"

newroot=$(repository_get_value newroot)
echo_local "Starting init-process ($init_cmd)..."
exit_linuxrc 0 "$init_cmd" "$newroot"

#********** main

###############
# $Log: linuxrc.generic.sh,v $
# Revision 1.98  2010-07-08 08:15:48  marc
# - errormsg reworked
# - reset nodeid/name if set in breakp shell
# - moved stopping of syslog down
#
# Revision 1.97  2010/06/29 19:00:06  marc
# moved killing of syslog down
#
# Revision 1.96  2010/06/25 12:27:12  marc
# upstream move. Calling *_get_valid_params for either clusterparams and fsparams.
#
# Revision 1.95  2010/06/17 08:18:19  marc
# - moved move_dev before services being restarted
# - added vg activation for additional fs if being used.
#
# Revision 1.94  2010/06/08 13:45:54  marc
# add scsi_failover to restart_scsi_newroot
#
# Revision 1.93  2010/05/27 09:54:09  marc
# - removed iscsistart (now in hardware-lib.sh)
# - added rootsource to lvm functions (only activate vg for rootfs)
#
# Revision 1.92  2010/04/23 10:13:32  marc
# Fixed bug that no xtab would be created.
#
# Revision 1.91  2010/04/13 14:07:58  marc
# support for scsi_failover and scsi_driver as bootparameter
#
# Revision 1.90  2010/03/08 13:06:28  marc
# - added sematic to check if / is mounted ro and then do no rw action
# - fixed bug with mountopts (ro/rw)
# - fixed bug with scsi-failover and scsifailover as bootparameter
#
# Revision 1.89  2010/02/21 12:05:56  marc
# there are no mount_opts but mountopts
#
# Revision 1.88  2010/02/05 12:46:24  marc
# - removed format characters or tabs or newlines where unnecessary
# - added being able to mount more filesystems other then only /
#
# Revision 1.87  2010/01/11 10:06:33  marc
# PYTHONPATH will only be set if python is available.
#
# Revision 1.86  2010/01/04 13:26:50  marc
# also passing nodeid to _ipConfig
#
# Revision 1.85  2009/12/09 10:58:42  marc
# cosmetics
# implemented move_dev function instead of plain here.
#
# Revision 1.84  2009/12/09 09:07:01  marc
# cosmetics
#
# Revision 1.83  2009/09/28 13:12:41  marc
# - Reimplemented syslog functionality
# - Removed deps to output channels 3,4
# - Some typos
#
# Revision 1.82  2009/08/19 16:10:44  marc
# another fix for bug358
#
# Revision 1.81  2009/08/11 09:59:29  marc
# Fixed bug #358 Initramfs consumes more and more during runtime. Which can lead to no free memory
#
# Revision 1.80  2009/06/04 15:18:54  reiner
# Modified usbLoad function. Now it works again and it is used to add USB keyboard support during boot process.
#
# Revision 1.79  2009/06/04 07:41:58  reiner
# Added additional LoadUSB code so that USB Keyboards work in Expertshell and before Interactive Mode begins.
#
# Revision 1.78  2009/04/20 07:12:44  marc
# - fixed a bug where a brigde would not eventually come up with binded to a bond interface (strange!)
#
# Revision 1.77  2009/04/14 14:58:49  marc
# - small bugfix with stepmode and i being pressed and step instead of set
# - added support for xfiles
#
# Revision 1.76  2009/03/06 15:03:02  marc
# fixed typos
#
# Revision 1.75  2009/03/06 13:25:48  marc
# - removed initial start of udev as it should be started implicitly on demand
# - fixed bug in network setup because devices would have been created multiple times
# - some typos
#
# Revision 1.74  2009/02/27 10:34:10  marc
# bugfix with static hardware detection
#
# Revision 1.73  2009/02/24 12:03:46  marc
# * added restricted hardwaredetection when drivers are specified
#
# Revision 1.72  2009/02/20 09:51:22  marc
# small changes in NIC detection
#
# Revision 1.71  2009/02/18 18:05:05  marc
# added driver for nic
#
# Revision 1.70  2009/02/08 14:23:49  marc
# added md
#
# Revision 1.69  2009/02/03 20:36:50  marc
# bugfix for multiple nics
#
# Revision 1.68  2009/02/02 20:13:40  marc
# - Bugfix in hardware detection
# - Introduced function to not load storage when not needed
#
# Revision 1.67  2009/01/29 15:58:24  marc
# Upstream with new HW Detection see bug#325
#
# Revision 1.66  2009/01/28 12:57:44  marc
# Many changes:
# - moved some functions to std-lib.sh
# - no "global" variables but repository
# - bugfixes
# - support for step with breakpoints
# - errorhandling
# - little clean up
# - better seperation from cc and rootfs functions
#
# Revision 1.65  2008/12/01 12:31:54  marc
# - more simulation stuff
# - fixed Bugs within filesystem_ro/filesystem_rw
#
# Revision 1.64  2008/11/18 08:48:28  marc
# - implemented RFE-BUG 289
#   - possiblilty to execute initrd from shell or insite initrd to analyse behaviour
#
# Revision 1.63  2008/10/28 12:51:48  marc
# fixed bug#288 where default mountoptions would always include noatime,nodiratime
#
# Revision 1.62  2008/10/28 12:25:47  marc
# bugfix
#
# Revision 1.61  2008/10/14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#
# Revision 1.60  2008/08/14 14:38:11  marc
# - changed parameter orders first clustertype/rootfs then the rest
# - hardware detection order (starting udev first)
# - more small fixes
#
# Revision 1.59  2008/07/03 12:45:27  mark
# rewrite of parameter collection to use new getParameter method
#
# Revision 1.58  2008/06/10 09:53:33  marc
# - beautified syslog handling
#
# Revision 1.57  2008/05/17 08:32:18  marc
# changed the time the /etc/hosts is created a little bit to later when nics are already up.
#
# Revision 1.56  2008/05/10 19:42:33  marc
# - Implemened RFE#218 generating right hosts also with using dhcp.
#
# Revision 1.55  2008/03/18 17:41:52  marc
# - fixed bug for not detecting failover in all cases.
# - Technology preview for drbd added.
#
# Revision 1.54  2008/01/24 15:25:21  marc
# fixed a syntax error.
#
# Revision 1.53  2008/01/24 13:26:12  marc
# - BUG#179 xen detection will not work with RHEL4 guest
# - BUG#178 nousb parameter can be specified
# - rewrote part of iscsi
#
# Revision 1.52  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.51  2007/10/18 08:04:38  mark
# fixes bug #144
#
# Revision 1.50  2007/10/16 08:02:41  marc
# - added get_rootsource
# - fixed BUG 142
# - lvm switch support
#
# Revision 1.49  2007/10/10 22:48:08  mark
# fixes BZ139
#
# Revision 1.48  2007/10/10 15:09:48  mark
# move usbstart out of for-loop
#
# Revision 1.47  2007/10/10 12:23:27  mark
# added syslog to chroot
#
# Revision 1.46  2007/10/10 11:05:22  marc
# readded inclusion of iscsi-lib if available
#
# Revision 1.45  2007/10/09 16:48:33  mark
# restart some cluster services in newroot (clvmd)
#
# Revision 1.44  2007/10/09 14:24:27  marc
# usbLoad fixed and more stabilized
#
# Revision 1.43  2007/10/08 16:13:55  mark
# source distrodependent boot-lib.sh
#
# Revision 1.42  2007/10/05 10:07:56  marc
# - added xen-support
#
# Revision 1.41  2007/10/02 12:16:02  marc
# - cosmetic changes to prevent unnecesarry ugly FAILED
#
# Revision 1.40  2007/09/27 09:34:32  marc
# - comment out copy_relevant_files because of problems with kudzu
#
# Revision 1.39  2007/09/26 11:56:02  marc
# cosmetic changes
#
# Revision 1.38  2007/09/26 11:40:48  mark
# moved network config before storage config
#
# Revision 1.37  2007/09/18 10:06:36  mark
# removed unneeded code
#
# Revision 1.36  2007/09/14 13:28:54  marc
# - Fixed Bug BZ#31
#
# Revision 1.35  2007/09/07 08:04:18  mark
# added cleanup_initrd
#
# Revision 1.34  2007/08/06 15:56:14  mark
# new chroot environment
# bootimage release 1.3
#
# Revision 1.33  2007/05/23 09:15:35  mark
# added support fur RHEL4u5
#
# Revision 1.32  2007/03/09 18:01:11  mark
# added support for nash like switchRoot
#
# Revision 1.31  2007/02/09 11:06:16  marc
# added nodeid and nodename
#
# Revision 1.30  2007/01/19 13:40:20  mark
# init_cmd uses full cmdline /proc/cmdline like nash
# fixes bug #21
#
# Revision 1.29  2006/11/10 11:37:10  mark
# modified quorumack user input
# added retry:3 waittime:5 to clusterfs_mount
#
# Revision 1.28  2006/10/06 08:35:15  marc
# added quorumack functionality
#
# Revision 1.27  2006/07/19 15:12:26  marc
# mulitpath dmapper bugfix with devices
#
# Revision 1.26  2006/07/13 14:14:57  marc
# udev_start as function
#
# Revision 1.25  2006/07/03 08:32:03  marc
# added step
#
# Revision 1.24  2006/06/19 15:56:13  marc
# added devicemapper support
#
# Revision 1.23  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.22  2006/05/12 13:02:24  marc
# Major changes for Version 1.0.
# Loads of Bugfixes everywhere.
#
# Revision 1.21  2006/05/07 11:34:58  marc
# major change to version 1.0.
# Complete redesign.
#
# Revision 1.20  2006/05/03 12:46:24  marc
# added documentation
#
# Revision 1.19  2006/01/28 15:10:23  marc
# added cvs tags
#
