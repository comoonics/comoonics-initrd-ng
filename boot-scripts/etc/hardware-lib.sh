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
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output
#****h* boot-scripts/etc/hardware-lib.sh
#  NAME
#    hardware-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for general hardware support functions.
#*******

#****f* hardware-lib.sh/hardware_start_services
#  NAME
#    udev_start
#  SYNOPSIS
#    function boot-lib.sh/udev_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function hardware_start_services() {
  local distribution=$(repository_get_value distribution)
  ${distribution}_hardware_start_services
}
#************hardware_start_services


#****f* hardware-lib.sh/udev_start
#  NAME
#    udev_start
#  SYNOPSIS
#    function boot-lib.sh/udev_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function udev_start() {
  local distribution=$(repository_get_value distribution)
  ${distribution}_udev_start
}
#************udev_start

#****f* hardware-lib.sh/udev_daemon_start
#  NAME
#    udev_daemon_start
#  SYNOPSIS
#    function boot-lib.sh/udev_daemon_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function udev_daemon_start() {
  local distribution=$(repository_get_value distribution)
  typeset -f ${distribution}_udev_daemon_start >/dev/null 2>&1 &&  ${distribution}_udev_daemon_start
}
#************hardware-lib.sh/udev_daemon_start

#****f* hardware-lib.sh/dev_start
#  NAME
#    dev_start
#  SYNOPSIS
#    function boot-lib.sh/dev_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function dev_start() {
	local basedir=""
	if [ -n "$1" ] && [ -d "$1" ]; then
        basedir="$1"
	fi
	[ -d ${basedir}/dev ] || mkdir ${basedir}/dev
    echo_local -n "Mounting dev "
    if ! mount -t devtmpfs -o mode=0755,nosuid udev ${basedir}/dev >/dev/null 2>&1; then
      if ! is_mounted ${basedir}/dev; then 
        mount -o mode=0755 -t tmpfs none ${basedir}/dev
        return_code $?
      else
        passed
      fi
    fi
    echo_local -n "Creating devices "
    exec_local create_std_devfs $basedir
    return_code
}
#************dev_start

create_std_devfs() {
	local basedir=${1:-/}
	local error=0
  	test -e ${basedir}/dev/fd      || ln -s ${basedir}/proc/self/fd ${basedir}/dev/fd || error=1
	test -e ${basedir}/dev/stdin   || ln -s /proc/self/fd/0 ${basedir}/dev/stdin >/dev/null 2>&1 || error=1
	test -e ${basedir}/dev/stdout  || ln -s /proc/self/fd/1 ${basedir}/dev/stdout >/dev/null 2>&1 || error=1
	test -e ${basedir}/dev/stderr  || ln -s /proc/self/fd/2 ${basedir}/dev/stderr >/dev/null 2>&1 || error=1
    test -e ${basedir}/dev/null    || mknod ${basedir}/dev/null c 1 3 || error=1
    test -e ${basedir}/dev/zero    || mknod ${basedir}/dev/zero c 1 5 || error=1
    test -e ${basedir}/dev/console || mknod ${basedir}/dev/console c 5 1 || error=1
    test -e ${basedir}/dev/ptmx    || mknod ${basedir}/dev/ptmx c 5 2 || error=1
    test -d ${basedir}/dev/mapper  || mkdir ${basedir}/dev/mapper || error=1
    test -d ${basedir}/dev/shm     || mkdir -m1777 ${basedir}/dev/shm || error=1
	test -e ${basedir}/dev/fd      || ln -s /proc/self/fd ${basedir}/dev/fd || error=1
    test -d ${basedir}/dev/pts     || mkdir ${basedir}/dev/pts || error=1
    is_mounted ${basedir}/dev/pts  || mount -t devpts -o gid=5,mode=620 /dev/pts ${basedir}/dev/pts || error=1
    is_mounted ${basedir}/dev/shm  || mount -t tmpfs  -o mode=1777,nosuid,nodev  tmpfs ${basedir}/dev/shm || error=1
    return $error
}	

#****f* hardware-lib.sh/move_dev
#  NAME
#    move_dev
#  SYNOPSIS
#    function boot-lib.sh/move_dev newroot
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function move_dev() {
  local newroot=$1
  mount --move /dev $newroot/dev &&
  # Have these devfiles still available
  test -e /dev/console || exec_local mknod /dev/console c 5 1 &&
  test -e /dev/kmsg    || exec_local mknod /dev/kmsg c 1 11
}
#************move_dev

#****f* boot-lib.sh/scsi_get_drivers
#  NAME
#    scsi_get_drivers
#  SYNOPSIS
#    function scsi_get_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function scsi_get_drivers {
	echo "sd_mod sg libata scsi_transport_fc sata_svw sata_mv scsi_mod"
}
#************ scsi_get_drivers

#****f* boot-lib.sh/scsi_start
#  NAME
#    scsi_start
#  SYNOPSIS
#    function boot-lib.sh/scsi_start(scsifailover, rootsource)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function scsi_start() {
  local scsifailover=$1
  shift
  local rootsource=$1
  shift
  local scsidrivers=$*
  echo_local "Starting scsi..."

  # SCSI should not be loaded with xen!!
  xen_domx_detect
  _xen=$?
  if [ $_xen -ne 0 ]; then
    echo_local -n "Loading scsi_disk Module..."
    exec_local modprobe sd_mod
    return_code

    echo_local -n "Loading sg.ko module"
    exec_local modprobe sg
    return_code

    if [ -n "$scsifailover" ] && [ "$scsifailover" = "rdac" ]; then
      mkdir /tmp &>/dev/null
      echo_local "RDAC Detected ($scsifailover)"
      echo_local -n "Loading mppUpper module"
      exec_local modprobe mppUpper
      return_code
    fi
  fi

  if [ -z "${scsi_drivers}" ] && [ -n "$modules_conf" ] && [ -e "$modules_conf" ]; then
    scsi_drivers=$(cat ${modules_conf} | awk '/scsi_hostadapter.*/ {print $3}')
  fi
  if [ -n "${scsi_drivers}" ]; then
    echo_local -n "Loading all detected SCSI modules ($scsi_drivers)"
    for hostadapter in $scsi_drivers; do
      exec_local modprobe ${hostadapter}
    done
    return_code
    exec_local udev_start $scsifailover
  else
    exec_local udev_start $scsifailover
  fi

  if [ -n "$scsifailover" ] && [ "$scsifailover" = "rdac" ]; then
    echo_local "Loading mppVhba module"
    exec_local modprobe mppVhba
    return_code
    echo_local -n "Starting mpp hotadd script"
    exec_local /usr/sbin/hot_add
    return_code
  fi

  if [ $_xen -ne 0 ]; then
#    if [ -x "/opt/atix/comoonics_cs/rescan_scsi" ]; then
#      /opt/atix/comoonics_cs/rescan_scsi -a
#    elif [ -z "$scsifailover" ] || [ "$scsifailover" != "rdac" ]; then
#      echo_local -n "Importing unconfigured scsi-devices..."
#      devs=$(find /proc/scsi -name "[0-9]*" 2> /dev/null)
#      channels=0
#      for dev in $devs; do
#        for channel in $channels; do
#          id=$(basename $dev)
#          echo_local -N -n "$dev On id $id and channel $channel"
#          add_scsi_device $id $channel $dev
#          return_code
#        done
#      done
#    fi

    # start iscsi if apropriate
    typeset -f is_iscsi_rootsource >/dev/null 2>&1 && is_iscsi_rootsource $rootsource
    if [ $? -eq 0 ]; then
	  load_iscsi
	  start_iscsi $rootsource
      stabilized -g 5 -t hash /proc/scsi/scsi
    fi

    echo_local_debug "Configured SCSI-Devices:"
    exec_local_debug /bin/cat /proc/scsi/scsi
  fi
}
#************ scsi_start

#****f* boot-lib.sh/scsi_restart_newroot
#  NAME
#    scsi_restart_newroot
#  SYNOPSIS
#    function boot-lib.sh/scsi_restart_newroot(scsifailover, rootsource, newroot, chroot)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function scsi_restart_newroot() {
    local failover=$1
    local rootsource=$2
    local newroot=$3
    local chroot=$4
    
    echo_local "Restarting scsi services in newroot $newroot"
    typeset -f is_iscsi_rootsource >/dev/null 2>&1 && is_iscsi_rootsource $rootsource
    if [ $? -eq 0 ]; then
	  restart_iscsi_newroot $rootsource $newroot $chroot
    fi
}
#************ scsi_start

#****f* boot-lib.sh/dm_mp_start
#  NAME
#    dm_mp_start
#  SYNOPSIS
#    function dm_mp_start
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function dm_mp_start() {
  echo_local -n "Loading dm-mutltipath.ko module"
  exec_local modprobe dm-multipath
  return_code

  stabilized -g 5 -t hash /proc/partitions
  echo_local -n "Setting up Multipath"
  exec_local multipath
  return_code
  [ -e /proc/partitions ] && stabilized --type=hash --interval=600 --good=5 /proc/partitions

  exec_local_debug multipath -l

  echo_local -n "Restarting udev "
  exec_local udev_start
  return_code
  [ -e /proc/partitions ] && stabilized --type=hash --interval=600 --good=5 /proc/partitions

  # Those devices should have been created by udev at this time. This why we leave them out.
#  echo_local -n "Setting up devicemapper partitions"
#  if [ -x /sbin/kpartx ]; then
#    /sbin/dmsetup ls --target multipath --exec "/sbin/kpartx -a"
#  fi
#  [ -e /proc/partitions ] && stabilized --type=hash --interval=600 --good=5 /proc/partitions
  return_code
}
#************ dm_mp_start

#****f* boot-lib.sh/usb_get_drivers
#  NAME
#    usb_get_drivers
#  SYNOPSIS
#    function usb_get_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function usb_get_drivers {
	echo "ehci_hcd ohci_hcd uhci_hcd hidp hpilo"
}
#************ usb_get_drivers

#****f* boot-lib.sh/usbLoad
#  NAME
#    usbLoad
#  SYNOPSIS
#    function usbLoad
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function usbLoad() {
	local modules=$(usb_get_drivers)
	for module in $modules; do
		grep $module /proc/modules >/dev/null 2>/dev/null || modprobe -q $module &>/dev/null
	done
	is_mounted /proc/bus/usb
	if [ $? -eq 1 ]; then
	  mount -t usbfs /proc/bus/usb /proc/bus/usb
	fi
	return 0
}
#************ usbLoad

#****f* boot-lib.sh/dm_start
#  NAME
#    dm_start
#  SYNOPSIS
#    function dm_start() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function dm_start {
  echo_local -n "Loading device mapper modules"
  for module in $(dm_get_drivers); do
    exec_local modprobe $module >/dev/null 2>&1
  done
  return_code $?
}
#************ dm_start

#****f* boot-lib.sh/dm_get_drivers
#  NAME
#    dm_get_drivers
#  SYNOPSIS
#    function dm_get_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function dm_get_drivers {
	echo "dm_round_robin dm_multipath dm_snapshot dm_mirror dm_mod scsi_dh scsi_dh_rdac"
}
#************ dm_get_drivers

#****f* boot-lib.sh/md_start
#  NAME
#    md_start
#  SYNOPSIS
#    function md_start() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function md_start {
  if [ -x "/sbin/mdadm" ]; then
    echo_local -n "Starting MD (software RAID) devices"
    exec_local mdadm --examine --scan > /etc/mdadm.conf
    exec_local mdadm --assemble --scan
    return_code $?
  fi
}
#******** md_start

#****f* boot-lib.sh/device_mapper_check
#  NAME
#    device_mapper_check
#  SYNOPSIS
#    function device_mapper_check $device
#  DESCRIPTION
#    checks if device is device mapper compatible or not.
#    Returns 0 on success 1 otherwise
#
function device_mapper_check {
	local device=$1
	# and if the device does not exist.
	if ! [ -e "$device" ] && [ -z "$device_mapper_check_stat_output" ]; then
		return 1
	# so but if the device does exist and has a major of 253/0xfd which is the dm device
	elif [ -b "$device" ] || [ -n "$device_mapper_dmsetup_output" ]; then
		if [ -n "$device_mapper_dmsetup_exit" ]; then
		    return $device_mapper_dmsetup_exit
		else
		    dmsetup status $device &>/dev/null
			return $?
		fi
    fi
	return 1
}
#************* device_mapper_check

#****f* boot-lib.sh/device_mapper_multipath_check
#  NAME
#    device_mapper_multipath_check
#  SYNOPSIS
#    function device_mapper_multipath_check $device
#  DESCRIPTION
#    checks if device is device mapper multipath compatible or not.
#    Returns 0 on success 1 otherwise
#
function device_mapper_multipath_check {
	local device=$1
    local partitionfilter='p[0-9][0-9]*'
	local mpdev=
	if device_mapper_check $device; then
		if [ -n "$device_mapper_multipath_check_multipath_return" ]; then
			return $device_mapper_multipath_check_multipath_return
		else
			multipathcmd=$(which multipath)
			mpdev=$(basename $device | sed -e 's/'${partitionfilter}'$//')
			$multipathcmd -l $mpdev 2>/dev/null
			return $?
		fi
	else
		return 1
	fi
}
#************* device_mapper_check

#****f* boot-lib.sh/lvm_check
#  NAME
#    lvm_check
#  SYNOPSIS
#    function lvm_check $device
#  DESCRIPTION
#    checks if device is lvm compatible or not.
#    Returns 0 on success 1 otherwise
#
function lvm_check {
	local device=$1
	local vg=$(lvm_get_vg $device)
	# in this case no lvm devices exist. So we check if we can get a vg from this device
	# and if the device does not exist.
	if [ -z "$vg" ] && ! [ -e "$device" ]; then
		return 1
	# so but if the device does exist and has a major of 253/0xfd which is the dm device and a vg also
	# we expect it to be lvm
	elif [ -n "$vg" ] && [ -b "$device" ]; then
	  device_mapper_check $device && lvm vgs $vg &>/dev/null
	  return $?
	elif [ -n "$vg" ]; then
	  # This is the case where the device is not existant but could be that the vg was not yet activated
      lvm vgs $vg &>/dev/null
      return $?
    fi
	return 1
}
#************* lvm_check

#****f* boot-lib.sh/lvm_start
#  NAME
#    lvm_start
#  SYNOPSIS
#    function lvm_start(rootdevice) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function lvm_start {
   local rootdevice=$1
   local volumegroup=$(lvm_get_vg $rootdevice)

   echo_local -n "Scanning for volume groups"
   exec_local lvm vgscan --ignorelockingfailure >/dev/null 2>&1
   return_code 0

   echo_local -n "Making device nodes"
   exec_local lvm vgmknodes --ignorelockingfailure >/dev/null 2>&1
   return_code 0

   echo_local -n "Activating volume group $volumegroup"
   exec_local lvm vgchange -ay  --ignorelockingfailure $volumegroup >/dev/null 2>&1
   return_code 0

   echo_local_debug "Found lvm devices (/dev/mapper): "
   lvm_devices=$(ls -1 /dev/mapper)
   echo_local_debug $lvm_devices
}
#******** lvm_start

#****f* boot-lib.sh/lvm_get_vg
#  NAME
#    lvm_get_vg
#  SYNOPSIS
#    function lvm_get_vg(rootdevice) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function lvm_get_vg {
   local device=$1
   local volumegroup=""
   local lv=""
   if [ "${device:0:11}" = "/dev/mapper" ]; then
     # {ddash} is if the vgname consists of a "-" in the name. Then the /dev/mapper device is xx--yy instead of xx-yy
     # we substitute -- with {ddash} for extracting the vgname and later on resubstitute it again this time with a 
     # single dash as the name itself has a single dash
     # What will be done if vgnames have double dash in the name? This is unsolved!
     echo ${device:12} | sed -e 's/--/{ddash}/g' -e 's/-[^-][^-]*$//' -e 's/{ddash}/-/g'
     return 0
   elif [ "${device:0:4}" = "/dev" ]; then
     vg=$(basename $(dirname $device))
     [ $vg == "dev" ] || echo $vg
     test -n "$vg" && test $vg != "dev"
     return $?
   fi
   return 1
}
#******** lvm_get_vg

#****f* boot-lib.sh/setHWClock
#  NAME
#    setHWClock
#  SYNOPSIS
#    function setHWClock() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function setHWClock() {
  # must be set before lock_gulmd is started.
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

  echo_local -n "Setting clock $CLOCKDEF: "$(date)
  exec_local /sbin/hwclock $CLOCKFLAGS
  return_code
}
#************ setHWClock

#****f* boot-lib.sh/hardware_detect
#  NAME
#    hardware_detect
#  SYNOPSIS
#    function hardware_detect()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function hardware_detect() {
  local drivers=$*
  local distribution=$(repository_get_value distribution)
  local driver=""
  
  /sbin/depmod -a &>/dev/null

  # modules not being removed
  local xmodules=$(cat /etc/xmodules 2>/dev/null)

  echo_local -n "Detecting Hardware "
  echo_local_debug -N -n "..(saving modules).."
  local modules=$( (listmodules; echo -e "$xmodules") | sort)
  # detecting xen
  xen_domx_detect
  if [ $? -eq 0 ]; then
	echo_local -n -N "..(xen DomX).."
	xen_domx_hardware_detect
    # Xen modules are not to be unloaded cause it does not work and makes no sense
	modules=$(xen_get_drivers)
#	drivers="$drivers xennet"
  elif [ -n "$drivers" ]; then
    for driver in $drivers; do
    	exec_local modprobe -q $driver 2>/dev/null
    done
  else 
    ${distribution}_hardware_detect
  fi
  return_c=$?
  local hwids=$(hardware_ids)
  repository_append_value hardwareids " $hwids"
  return_code $return_c
  
  unload_modules ${modules[@]}

  echo_local_debug "Loaded modules"
  exec_local_debug cat /proc/modules 

  return $return_c
}

unload_modules() {
  local modules=$@
  local allowedunloadmodules=$(find /lib/modules/$(uname -r)/kernel/drivers \( -path "*/net/*" -type f -or -type l \) -printf "%f\n")
  local remove_times=4
  local _modules=""
  local _xclude=0
  local i=0
  echo_local -n "Removing loaded modules"
  _modules=$(listmodules | sort)
  while [ -n "$(unused_modules)" ] && [ $i -le $remove_times ] && [ "$modules" != "$_modules" ]; do
    for _module in $(unused_modules); do
      _xclude=0
	  if [ -n "$modules" ]; then
	    for _smodule in $modules; do
  		  if [ "$_module" == "$_smodule" ]; then
  		    _xclude=1
  		  fi
  	    done
  	    if [ $_xclude -eq 0 ]; then
  	      unload_module $_module $allowedunloadmodules
  	    fi
  	  else
        unload_module $_module $allowedunloadmodules
      fi
    done
    _modules=$(listmodules | sort)
    i=$(($i + 1))
  done
  [ -e /proc/modules ] && stabilized --type=hash --interval=600 --good=5 /proc/modules
  return_code
}
#************ hardware_detect

#****f* hardware-lib.sh/listmodules
#  NAME
#    listmodules
#  SYNOPSIS
#    function listmodules()
#  DESCRIPTION
#    lists all names of loaded modules
#  SOURCE
#
function listmodules {
  lsmod | awk '$2 ~ /[[:digit:]]+/ {print $1; }'
}
#************ listmodules

#****f* hardware-lib.sh/modprobe
#  NAME
#    modprobe
#  SYNOPSIS
#    function modprobe()
#  DESCRIPTION
#    lists all names of loaded modules
#  SOURCE
#
modprobe() {
	if [ -n "$1" ] && [ "$1" != "ignore" ] && [ "x$(basename $1 2>/dev/null)x" != "xtruex" ]; then
	  /sbin/modprobe $*
	fi
}
#************ modprobe

#****f* hardware-lib.sh/used_modules
#  NAME
#    used_modules
#  SYNOPSIS
#    function used_modules( module)
#  DESCRIPTION
#    lists all names of modules that are used by this module
#    return 0 if modules used found else return 1.
#  SOURCE
#
used_modules() {
	local module=$1
	if [ -z "$loadedmodules" ]; then
		cat /proc/modules
	else
		echo "$loadedmodules"
	fi | awk -v module="$module" '
$1==module && $3>0 && $5=="Live" { 
  print $4;
  exit 0; 
}
END {
	exit 1;
}
'
}
#************ used_modules

unused_modules() {
	if [ -z "$loadedmodules" ]; then
		cat /proc/modules
	else
		echo "$loadedmodules"
	fi | awk '
$3==0 && $5=="Live" {
	print $1;
}
'
}

#****f* hardware-lib.sh/unload_module
#  NAME
#    unload_module
#  SYNOPSIS
#    function unload_module(module, allowedmodules)
#  DESCRIPTION
#    lists all names of loaded modules
#  SOURCE
#
unload_module() {
	if [ -n "$1" ] && [ "$1" != "ignore" ] && [ "$(basename $1)" != "true" ]; then
		local module=$1
		local _module
		local ret=0
		shift
		local allowedmodules=$@
		if [ -z "$allowedmodules" ]; then
			modprobe -q -r $module
			ret=$?
		else
		    for _module in $allowedmodules; do
		    	# remove .ko from the end of the module (might be there)
		    	_module=${_module%.ko}
		    	if [ "$module" = "$_module" ]; then
		    		modprobe -q -r $module
		    		ret=$?
		    	fi
		    done
	    fi
	fi
	return $ret
}
#************ modprobe

#****f* hardware-lib.sh/hardware_ids
#  NAME
#    hardware_ids
#  SYNOPSIS
#    function hardware_ids(silent=0)
#  DESCRIPTION
#    lists all macaddresses.
#    Default is format: {resource}: {id}, means implicitly {nic}: {mac} or 
#    if silent=1 a list of ids, which means implicictly
#     {mac}
#     {mac}
#     ..
#  SOURCE
#
function hardware_ids {
  local link_was_up=0
  local silent=${1}
  for nic in $(found_nics); do
  	if test "$(cat /sys/class/net/${nic}/carrier 2>/dev/null)" = "1"; then
  	  link_was_up=1
  	fi
  	  		
  	test $link_was_up -eq 0 && ip link set $nic up &>/dev/null
  	
    if [ -f /sys/class/net/${nic}/address ] && [ -f /sys/class/net/${nic}/type ] && [ "$(cat /sys/class/net/${nic}/type)" -lt 256 ]; then
  	  [ -n "$silent" ] && echo -n "${nic}:" 
  	  cat /sys/class/net/${nic}/address | tr [a-f] [A-F]
    fi
  	test $link_was_up -eq 0 && ip link set $nic down &>/dev/null
  done
}
#************ hardware_ids

#****f* boot-lib.sh/add_scsi_device
#  NAME
#    add_scsi_device
#  SYNOPSIS
#    function add_scsi_device() {
#  DESCRIPTION
#    adds all scsi-devices found by the fibrechannel driver qla2x00 to
#    the linux kernel via the command "add-single-device" to /proc/scsi/scsi
#  SOURCE
#
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
#************ add_scsi_device

#****f* boot-lib.sh/validate_storage
#  NAME
#    validate_storage
#  SYNOPSIS
#    function validate_storage() {
#  DESCRIPTION
#    Validates the storage setup
#  SOURCE
#
function validate_storage() {
	return 0
}
#************ validate_storage

#****f* boot-lib.sh/storage_get_drivers
#  NAME
#    storage_get_drivers
#  SYNOPSIS
#    function storage_get_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function storage_get_drivers {
	xen_domx_detect
	if [ $? -eq 0 ]; then
		xen_get_drivers
	else
		scsi_get_drivers
	fi
	dm_get_drivers

	# check for drbd
	typeset -f isDRBDRootsource >/dev/null 2>&1 && isDRBDRootsource $(repository_get_value rootsource)
	if [ $? -eq 0 ]; then
		drbd_get_drivers
	fi		
	# check for iscsi
	typeset -f isISCSIRootsource >/dev/null 2>&1 && isISCSIRootsource $(repository_get_value rootsource)
	if [ $? -eq 0 ]; then
		scsi_get_drivers
		iscsi_get_drivers
	fi
}
#************ storage_get_drivers

#****f* boot-lib.sh/get_default_drivers
#  NAME
#    get_default_drivers
#  SYNOPSIS
#    function get_default_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function get_default_drivers {
	echo "$DEFAULT_MODULES"
}
#************ get_default_drivers

#****f* hardware-lib.sh/sysctl_load
#  NAME
#    sysctl_load
#  SYNOPSIS
#    function sysctl_load() {
#  DESCRIPTION
#    Loads the sysctls if available
#  SOURCE
#
function sysctl_load() {
	local sysctlconf="$1"
	[ -z "$sysctlconf" ] && sysctlconf="/etc/sysctl.conf" 
	if [ -e "$sysctlconf" ]; then
		echo_local -n "Loading sysctl.."
		echo_local_debug -N -n "sysctl.conf: $sysctlconf"
		exec_local "sysctl -q -p $sysctlconf > /dev/null"
		return_code
	fi
}
#**************** sysctl_load

#****f* hardware-lib.sh/stabilized
#  NAME
#    stabilized
#  SYNOPSIS
#    function stabilized() {
#  DESCRIPTION
#    Loads the sysctls if available
#  SOURCE
#
stabilized() {
  test -x /usr/bin/stabilized && /usr/bin/stabilized $* || /bin/true
}
#***************** stabilized
