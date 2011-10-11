#
# $Id: hardware-lib.sh,v 1.52 2010-08-12 09:54:51 marc Exp $
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
	test -e ${basedir}/dev/fd || ln -s ${basedir}/proc/self/fd ${basedir}/dev/fd
    echo_local -n "Mounting dev "
    is_mounted ${basedir}/dev
    if [ $? -ne 0 ]; then 
      mount -o mode=0755 -t tmpfs none ${basedir}/dev
      return_code $?
    else
      passed
    fi

    echo_local -n "Creating devices "
	test -e ${basedir}/dev/fd ||      ln -s ${basedir}/proc/self/fd ${basedir}/dev/fd
    test -e ${basedir}/dev/stdin ||   exec_local ln -s ${basedir}/dev/fd/0 ${basedir}/dev/stdin
    test -e ${basedir}/dev/stdout ||  exec_local ln -s ${basedir}/dev/fd/1 ${basedir}/dev/stdout
    test -e ${basedir}/dev/stderr ||  exec_local ln -s ${basedir}/dev/fd/2 ${basedir}/dev/stderr
    test -d ${basedir}/dev/pts ||     exec_local mkdir ${basedir}/dev/pts
    is_mounted ${basedir}/dev/pts ||  exec_local mount -t devpts -o gid=5,mode=620 /dev/pts ${basedir}/dev/pts
    test -d ${basedir}/dev/mapper ||  exec_local mkdir ${basedir}/dev/mapper
    test -d ${basedir}/dev/shm ||     exec_local mkdir -m1777 ${basedir}/dev/shm
    test -e ${basedir}/dev/null ||    exec_local mknod ${basedir}/dev/null c 1 3
    test -e ${basedir}/dev/zero ||    exec_local mknod ${basedir}/dev/zero c 1 5
    test -e ${basedir}/dev/systty ||  exec_local mknod ${basedir}/dev/systty c 4 0
    test -e ${basedir}/dev/tty ||     exec_local mknod ${basedir}/dev/tty c 5 0
    test -e ${basedir}/dev/console || exec_local mknod ${basedir}/dev/console c 5 1
    test -e ${basedir}/dev/ptmx ||    exec_local mknod ${basedir}/dev/ptmx c 5 2
    test -e ${basedir}/dev/rtc ||     exec_local mknod ${basedir}/dev/rtc c 10 135
    test -e ${basedir}/dev/tty0    || exec_local mknod ${basedir}/dev/tty0 c 4 0
    test -e ${basedir}/dev/tty1    || exec_local mknod ${basedir}/dev/tty1 c 4 1
    test -e ${basedir}/dev/tty2    || exec_local mknod ${basedir}/dev/tty2 c 4 2
    test -e ${basedir}/dev/tty3    || exec_local mknod ${basedir}/dev/tty3 c 4 3
    test -e ${basedir}/dev/tty4    || exec_local mknod ${basedir}/dev/tty4 c 4 4
    test -e ${basedir}/dev/tty5    || exec_local mknod ${basedir}/dev/tty5 c 4 5
    test -e ${basedir}/dev/tty6    || exec_local mknod ${basedir}/dev/tty6 c 4 6
    test -e ${basedir}/dev/tty7    || exec_local mknod ${basedir}/dev/tty7 c 4 7
    test -e ${basedir}/dev/tty8    || exec_local mknod ${basedir}/dev/tty8 c 4 8
    test -e ${basedir}/dev/tty9    || exec_local mknod ${basedir}/dev/tty9 c 4 9
    test -e ${basedir}/dev/tty10   || exec_local mknod ${basedir}/dev/tty10 c 4 10
    test -e ${basedir}/dev/tty11   || exec_local mknod ${basedir}/dev/tty11 c 4 11
    test -e ${basedir}/dev/tty12   || exec_local mknod ${basedir}/dev/tty12 c 4 12
    test -e ${basedir}/dev/ttyS0   || exec_local mknod ${basedir}/dev/ttyS0 c 4 64
    test -e ${basedir}/dev/ttyS1   || exec_local mknod ${basedir}/dev/ttyS1 c 4 65
    test -e ${basedir}/dev/ttyS2   || exec_local mknod ${basedir}/dev/ttyS2 c 4 66
    test -e ${basedir}/dev/ttyS3   || exec_local mknod ${basedir}/dev/ttyS3 c 4 67
    test -e ${basedir}/dev/kmsg    || exec_local mknod ${basedir}/dev/kmsg c 1 11
    test -e ${basedir}/dev/log     || ( which mksock >/dev/null 2>&1 && exec_local mksock ${basedir}/dev/log && exec_local chmod 666 ${basedir}/dev/log )
    
    return_code
}
#************dev_start

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

  if [ -z "${scsi_drivers}" ]; then
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
    if [ -x "/opt/atix/comoonics_cs/rescan_scsi" ]; then
      /opt/atix/comoonics_cs/rescan_scsi -a
    elif [ -z "$scsifailover" ] || [ "$scsifailover" != "rdac" ]; then
      echo_local -n "Importing unconfigured scsi-devices..."
      devs=$(find /proc/scsi -name "[0-9]*" 2> /dev/null)
      channels=0
      for dev in $devs; do
        for channel in $channels; do
          id=$(basename $dev)
          echo_local -N -n "$dev On id $id and channel $channel"
          add_scsi_device $id $channel $dev
          return_code
        done
      done
    fi

    # start iscsi if apropriate
    typeset -f is_iscsi_rootsource >/dev/null 2>&1 && is_iscsi_rootsource $rootsource
    if [ $? -eq 0 ]; then
	  load_iscsi
	  start_iscsi $rootsource
    fi

    stabilized -g 5 -t hash /proc/scsi/scsi
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

  echo_local -n "Setting up devicemapper partitions"
  if [ -x /sbin/kpartx ]; then
    /sbin/dmsetup ls --target multipath --exec "/sbin/kpartx -a"
  fi
  [ -e /proc/partitions ] && stabilized --type=hash --interval=600 --good=5 /proc/partitions
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
	local invalid_majors="8 ca"
	local valid_majors="fd"
	local vg=$(lvm_get_vg $device)
	# in this case no lvm devices exist. So we check if we can get a vg from this device
	# and if the device does not exist.
	if [ -n "$vg" ] && ! [ -e "$device" ]; then
		return 0
	# so but if the device does exist and has a major of 253/0xfd which is the dm device and a vg also
	# we expect it to be lvm
	elif [ -n "$vg" ] && [ -b "$device" ]; then
		major=$(stat --dereference --format="%t" $device)
		for _major in $valid_majors; do
			if [ "$major" = "$_major" ]; then
				return 0
			fi
		done
	    return 1
	elif [ -e "$device" ]; then
		major=$(stat --dereference --format="%t" $device)
		for _major in $invalid_majors; do
			if [ "$major" = "$_major" ]; then
				return 1
			fi
		done
    fi
	return 0
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
     echo ${device:12} | sed -e 's/-\S\S*$//'
     return 0
   elif [ "${device:0:4}" = "/dev" ]; then
     vg=$(basename $(dirname $device))
     [ $vg == "dev" ] || echo $vg
     return 0
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
#    function hardware_ids()
#  DESCRIPTION
#    lists all names of loaded modules
#  SOURCE
#
function hardware_ids {
  ifconfig -a | grep -v -i "Link encap: Local" | grep -v -i "Link encap:UNSPEC" | grep -i hwaddr | awk 'BEGIN{OFS=":";}{print $1,$5;};'
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

#############
# $Log: hardware-lib.sh,v $
# Revision 1.52  2010-08-12 09:54:51  marc
# fixed bug with mksock query
#
# Revision 1.51  2010/08/12 07:35:33  marc
# lvm_check():
#   fixed bug with error message when there is no lvm device
#
# Revision 1.50  2010/08/11 09:41:44  marc
# be quite when loading usb modules
#
# Revision 1.49  2010/07/12 14:19:53  marc
# typo in modprobe
#
# Revision 1.48  2010/07/08 13:16:46  marc
# typo
#
# Revision 1.47  2010/07/08 08:10:08  marc
# - dev_start: moved the creation of fd devices up
#
# Revision 1.46  2010/06/17 08:17:28  marc
# - lvm_check: more stable
# - lvm_get_vg: detection of vg more generic
#
# Revision 1.45  2010/05/27 09:47:37  marc
# scsi_start:
#    - added rootsource as second paramter for iscsi to be started here
#    - added starting of iscsi
# scsi_restart_newroot:
#    - for services to be restarted in newroot (e.g. iscsid)
# usb_get_drivers
#    - added driver hp_ilo for ILO remote consoles not over serial
# lvm_start
#    - added parameter rootsource
#    - only activate the volumegroup found in rootsource or activate all
# lvm_get_vg (new)
#    - returns the vg of the given device
#
# Revision 1.44  2010/04/23 10:12:39  marc
# fixed bug with starting of udevd.
#
# Revision 1.43  2010/04/13 14:07:22  marc
# - fixed rdac implementation
#
# Revision 1.42  2010/03/08 13:09:40  marc
# dm_start might take scsi_failover as param
#
# Revision 1.41  2010/02/05 12:35:58  marc
# - some typos
#
# Revision 1.40  2010/01/11 10:05:08  marc
# added function stabilized to also work without
#
# Revision 1.39  2009/12/09 10:57:15  marc
# cosmetics
# no removement of modules with xen
#
# Revision 1.38  2009/10/07 12:03:35  marc
# - Fixes bug 365 where the bootprocess might hang while booting a clusternode
#
# Revision 1.37  2009/09/28 13:01:50  marc
# moved devices from boot-lib.sh/initEnv to dev_start
#
# Revision 1.36  2009/08/11 09:54:58  marc
# - latest mdadm fixes (Gordan Bobic)
# - Moved dm_get_drivers to be called in xen and others
#
# Revision 1.35  2009/06/04 15:18:54  reiner
# Modified usbLoad function. Now it works again and it is used to add USB keyboard support during boot process.
#
# Revision 1.34  2009/04/22 11:37:33  marc
# - fixed small bug in modules loading
# - introduced a file /etc/xmodules that will not be removed if loaded
#
# Revision 1.33  2009/04/20 12:23:55  marc
# added dm_multipath modules needed with rhel5
#
# Revision 1.32  2009/04/16 12:04:06  reiner
# Fixed typo in usbLoad function that prohibited proper usb keyboard detection. See bz341.
#
# Revision 1.31  2009/04/14 14:56:04  marc
# - extended storage_get_drivers to work with drbd, iscsi and xen
# - more modules for dm_multipath and ..
#
# Revision 1.30  2009/03/25 13:52:14  marc
# - added get_drivers functions to return modules in more general
#
# Revision 1.29  2009/03/06 13:22:47  marc
# always call modprunload_moduleead of anything else
#
# Revision 1.28  2009/02/27 10:33:51  marc
# changed the calling of modprobe to use the function
#
# Revision 1.27  2009/02/25 10:36:39  marc
# fixed bug with xennet hardware_detection
#
# Revision 1.26  2009/02/24 12:01:05  marc
# * added function modprobe to overwrite command.
# * added restricted hardwaredetection when drivers are specified
#
# Revision 1.25  2009/02/08 14:23:37  marc
# added md
#
# Revision 1.24  2009/02/08 13:14:29  marc
# stable module removement
#
# Revision 1.23  2009/02/02 20:12:25  marc
# - Bugfix in Hardwaredetection
#
# Revision 1.22  2009/01/29 15:58:06  marc
# Upstream with new HW Detection see bug#325
#
# Revision 1.21  2009/01/28 12:54:18  marc
# Many changes:
# - moved some functions to std-lib.sh
# - no "global" variables but repository
# - bugfixes
# - support for step with breakpoints
# - errorhandling
# - little clean up
# - better seperation from cc and rootfs functions
#
# Revision 1.20  2008/11/18 08:48:28  marc
# - implemented RFE-BUG 289
#   - possiblilty to execute initrd from shell or insite initrd to analyse behaviour
#
# Revision 1.19  2008/11/05 16:01:48  reiner
# Fixed small typo.
#
# Revision 1.18  2008/08/14 14:33:27  marc
# - remove debug output of modules.conf which is not needed any more
#
# Revision 1.17  2008/06/10 09:57:50  marc
# - added xen major for lvm_check
#
# Revision 1.16  2008/01/24 13:31:46  marc
# - BUG#170, udev with dm-multipath and RHEL5 is not working. reviewed the udev and stabilized more often
#
# Revision 1.15  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.14  2007/10/16 08:02:00  marc
# - lvm switch support (lvm_check)
#
# Revision 1.13  2007/10/09 14:24:15  marc
# usbLoad fixed and more stabilized
#
# Revision 1.12  2007/10/05 10:07:07  marc
# - added xen-support
#
# Revision 1.11  2007/10/02 12:14:49  marc
# - adding a sleep before lvm starts (did not work without, udev is to slow)
# - cosmetic changes
#
# Revision 1.10  2007/09/26 11:40:18  mark
# removed udev_start from hardware detection
#
# Revision 1.9  2007/09/17 09:27:01  marc
# - added another dep needed with #116
#
# Revision 1.8  2007/09/14 13:27:38  marc
# - Feature add rdac support (scsifailover=rdac)
#
# Revision 1.7  2007/09/07 08:02:30  mark
# made udev_start distro dependend
#
# Revision 1.6  2007/02/23 16:42:01  mark
# modified dm_mp_start to recognize all partitions
#
# Revision 1.5  2006/07/19 15:12:55  marc
# added another udev restart
#
# Revision 1.4  2006/07/13 11:36:34  marc
# added udev_start as function
#
# Revision 1.3  2006/06/19 15:55:45  marc
# added device mapper support
#
# Revision 1.2  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
