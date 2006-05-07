#
# $Id: hardware-lib.sh,v 1.1 2006-05-07 11:33:40 marc Exp $
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

#****f* boot-lib.sh/scsi_start
#  NAME
#    loadSCSI
#  SYNOPSIS
#    function boot-lib.sh/scsi_start() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function scsi_start() {
  echo_local "Starting scsi-driver..."

  echo_local -n "Loading scsi_disk Module..."
  exec_local /sbin/modprobe sd_mod
  return_code

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
	
  echo_local "Importing unconfigured scsi-devices..."
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
  echo_local_debug "3.3 Configured SCSI-Devices:"
  exec_local_debug /bin/cat /proc/scsi/scsi

} 
#************ scsi_start 

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
   echo_local -n "Loading LVM"

   # Test because fencing is not working properly
   #mount -o mode=0755 -t tmpfs none /dev
   #mknod /dev/console c 5 1
   #mknod /dev/null c 1 3
   #mknod /dev/zero c 1 5
   #mkdir /dev/pts
   #mkdir /dev/shm
	
   modprobe dm_mod >/dev/null 2>&1
   return_code $?

   #/sbin/udevstart
   echo_local -n Scanning logical volumes
   lvm vgscan >/dev/null 2>&1
   return_code $?

   echo_local -n Activating logical volumes
   lvm vgchange -ay >/dev/null 2>&1
   return_code $?

   echo_local -n Making device nodes
   lvm vgmknodes >/dev/null 2>&1
   return_code $?

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
  ${distribution}_hardware_detect
  return_code

  echo_local -n "Module-depency"
  exec_local /sbin/depmod -a
  return_code

  echo_local -n "Starting udev"
  exec_local /sbin/udevstart
  return_code

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
# Revision 1.1  2006-05-07 11:33:40  marc
# initial revision
#
