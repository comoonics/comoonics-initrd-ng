#
# $Id: hardware-lib.sh,v 1.13 2007-10-09 14:24:15 marc Exp $
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
    ${distribution}_hardware_start_services
    return_code
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
	echo_local -n "Starting udev ..."
	${distribution}_udev_start
    return_code
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
    echo_local -n "Mounting dev "
    exec_local mount -o mode=0755 -t tmpfs none /dev
    return_code

    echo_local -n "Creating devices "
    exec_local mknod /dev/console c 5 1 &&
    exec_local mknod /dev/null c 1 3 &&
    exec_local mknod /dev/zero c 1 5 &&
    exec_local mkdir /dev/pts &&
    exec_local mkdir /dev/shm
    return_code
}
#************dev_start

#****f* boot-lib.sh/scsi_start
#  NAME
#    scsi_start
#  SYNOPSIS
#    function boot-lib.sh/scsi_start(scsifailover)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function scsi_start() {
  local scsifailover=$1
  echo_local "Starting scsi-driver..."

  # SCSI should not be loaded with xen!!
  xen_domx_detect
  _xen=$?
  if [ $_xen -ne 0 ]; then
    echo_local -n "Loading scsi_disk Module..."
    exec_local /sbin/modprobe sd_mod
    return_code

    echo_local -n "Loading sg.ko module"
    exec_local /sbin/modprobe sg
    return_code

    if [ -n "$scsifailover" ] && [ "$scsifailover" = "rdac" ]; then
      mkdir /tmp &>/dev/null
      echo_local "RDAC Detected ($scsifailover)"
      echo_local -n "Loading mppUpper module"
      exec_local modprobe mppUpper
      return_code
    fi
  fi

  if [ -n "${FC_MODULES}" ]; then
    echo_local -n "Loading $FC_MODULES"
    exec_local /sbin/modprobe ${FC_MODULES}
    return_code
  else
    echo_local -n "Loading all detected SCSI modules"
    for hostadapter in $(cat ${modules_conf} | awk '/scsi_hostadapter.*/ {print $3}'); do
      exec_local /sbin/modprobe ${hostadapter}
    done
    return_code
  fi
  step

  if [ -n "$scsifailover" ] && [ "$scsifailover" = "rdac" ]; then
    echo_local "Loading mppVhba module"
    exec_local /sbin/modprobe mppVhba
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
          echo_local -n "$dev On id $id and channel $channel"
          add_scsi_device $id $channel $dev
          return_code
        done
      done
    fi
    echo_local_debug "3.3 Configured SCSI-Devices:"
    exec_local_debug /bin/cat /proc/scsi/scsi
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

  echo_local -n "Setting up Multipath"
  exec_local multipath
  return_code

  exec_local_debug multipath -l

  echo_local -n "Restarting udev "
  exec_local udev_start
  return_code

  echo_local -n "Setting up devicemapper partitions"
  if [ -x /sbin/kpartx ]; then
    /sbin/dmsetup ls --target multipath --exec "/sbin/kpartx -a"
  fi

  return_code
}
#************ dm_mp_start

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
	modules="ehci_hcd ohci_hcd uhci_hcd hidp"
	for module in modules; do
		modprobe $module
	done
	mount -t usbfs /proc/bus/usb /proc/bus/usb
}
#************ dm_mp_start

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

  echo_local -n "Setting up Multipath"
  exec_local multipath
  return_code

  exec_local_debug multipath -l

  echo_local -n "Restarting udev "
  exec_local udev_start
  return_code

  echo_local -n "Setting up devicemapper partitions"
  if [ -x /sbin/kpartx ]; then
    /sbin/dmsetup ls --target multipath --exec "/sbin/kpartx -a"
  fi

  return_code
}
#************ dm_mp_start

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
   # Test because fencing is not working properly
   #mount -o mode=0755 -t tmpfs none /dev
   #mknod /dev/console c 5 1
   #mknod /dev/null c 1 3
   #mknod /dev/zero c 1 5
   #mkdir /dev/pts
   #mkdir /dev/shm

   echo_local -n "Loading device mapper modules"
   exec_local modprobe dm_mod >/dev/null 2>&1 &&
   exec_local modprobe dm-mirror  >/dev/null 2>&1 &&
   exec_local modprobe dm-mirror >/dev/null 2>&1 &&
   exec_local modprobe dm-snapshot >/dev/null 2>&1
   return_code $?

   #/sbin/udevstart
}
#************ dm_start

#****f* boot-lib.sh/lvm_start
#  NAME
#    lvm_start
#  SYNOPSIS
#    function lvm_start() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function lvm_start {
   echo_local -n "Scanning logical volumes"
   exec_local lvm vgscan --ignorelockingfailure >/dev/null 2>&1
   return_code 0

   echo_local -n "Activating logical volumes"
   exec_local lvm vgchange -ay  --ignorelockingfailure >/dev/null 2>&1
   return_code 0

   echo_local -n "Making device nodes"
   exec_local lvm vgmknodes --ignorelockingfailure >/dev/null 2>&1
   return_code 0

   echo_local_debug "Found lvm devices (/dev/mapper): "
   lvm_devices=$(ls -1 /dev/mapper)
   echo_local_debug $lvm_devices

   #exec_local ${LVM_VG_SCAN}
   #exec_local ${LVM_VG_CHANGE} -ay $pool_name
}
#******** lvm_start

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
  echo_local -n "Detecting Hardware "
  # detecting xen
  xen_domx_detect
  if [ $? -eq 0 ]; then
	echo_local -n "..(xen DomX).."
	xen_domx_hardware_detect
  else
    ${distribution}_hardware_detect
  fi
  return_code

  echo_local -n "Module-depency"
  exec_local /sbin/depmod -a
  return_code

#  echo_local -n "Starting udev"
#  udev_start
#  return_code

  echo_local_debug "File $modules_conf ***"
  exec_local_debug cat $modules_conf

  return $ret_c
}
#************ hardware_detect

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

#############
# $Log: hardware-lib.sh,v $
# Revision 1.13  2007-10-09 14:24:15  marc
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
