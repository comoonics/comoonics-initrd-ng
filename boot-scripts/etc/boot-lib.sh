#
# $Id: boot-lib.sh,v 1.30 2006-05-07 11:37:15 marc Exp $
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
#****h* comoonics-bootimage/boot-lib.sh
#  NAME
#    boot-lib.sh
#    $id$
#  DESCRIPTION
#*******

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
newroot="/"
mount_point="/mnt/newroot"

#****f* boot-lib.sh/usage
#  NAME
#    usage
#  SYNOPSIS
#    function usage() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function usage() {
    echo "$0 [-R] [-s|S] [-d|D] [-h]"
    echo -e "\t-R: non recursive for nfs-mounts (experimental or obsolete)"
    echo -e "\t-s|S: set stepmode (s) or unset stepmode (S)"
    echo -e "\t-d|D: set debugmode (d) or unset stepmode (D)"
    echo -e "\t-h:   this usage."
}
#************ usage 

#****f* boot-lib.sh/check_cmd_params
#  NAME
#    check_cmd_params
#  SYNOPSIS
#    function check_cmd_params() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ check_cmd_params 

#****f* boot-lib.sh/exit_linuxrc
#  NAME
#    exit_linuxrc
#  SYNOPSIS
#    function exit_linuxrc() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function exit_linuxrc() {
    error_code=$1
    if [ -n "$2" ]; then 
      init_cmd=$2
    fi
    if [ -n "$3" ]; then 
      newroot=$3
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
	echo_local "Writing $init_cmd $newroot => $init_cmd_file"
	echo "$init_cmd $newroot" > $init_cmd_file
	exit $error_code
    fi
}
#************ exit_linuxrc 

#****f* boot-lib.sh/step
#  NAME
#    step
#  SYNOPSIS
#    function step() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function step() {
   if [ ! -z "$stepmode" ]; then
     echo_out -n "Press <RETURN> to continue ..."
     read -t$step_timeout __the_step
     [ "$__the_step" = "quit" ] && exit_linuxrc 2
     if [ "$__the_step" = "continue" ]; then
       stepmode=
     fi
     if [ -z "$__the_step" ]; then
       echo_out
     fi
   else
     return 0
   fi
}
#************ step 

#****f* boot-lib.sh/getBootParm
#  NAME
#    getBootParm
#  SYNOPSIS
#    function getBootParm(param, [default])
#  DESCRIPTION
#    Gets the given parameter from the bootloader command line. If not
#    found default or the empty string is returned.
#  SOURCE
#
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
#************ getBootParm 

#****f* boot-lib.sh/exec_nondefault_boot_source
#  NAME
#    exec_nondefault_boot_source
#  SYNOPSIS
#    function exec_nondefault_boot_source() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ exec_nondefault_boot_source 

#****f* boot-lib.sh/getDistribution
#  NAME
#    getDistribution
#  SYNOPSIS
#    funtion getDistribution
#  DESCRIPTION
#    returns the name of the Linux Distribution right now only redhat
#    works. Else an undefined value is returned.
#  SOURCE
function getDistribution {
#   if [ -e /etc/redhat-release ]; then
#     cat /etc/redhat-release | grep -i "Red Hat Enterprise Linux ES release 4" > /dev/null 2>&1
#     if [ $? -eq 0 ]; then
       echo "rhel4"
#     fi
#   else
#     return 2
#   fi
}
#**** getDistribution

#****f* boot-lib.sh/getBootParameters
#  NAME
#    getBootParameters
#  SYNOPSIS
#    function getBootParameters() {
#  DESCRIPTION
#    sets all clusterfs relevant parameters given by the bootloader 
#    via /proc/cmdline as global variables.
#    The following global variables are set
#      * debug: debug mode (bootparm com-debug unset)
#      * stepmode: step mode (bootparm com-step unset)
#      * mountopts: mountopts (bootparm mountopts defaults)
#      * tmpfix: mount tmp as ramfs (bootparm tmpfix unset)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getBootParameters() {
    getBootParm com-debug
    getBootParm com-step
    getBootParm mountopt defaults
    getBootParm tmpfix
}
#************ getBootParameters 

#****f* boot-lib.sh/initBootProcess
#  NAME
#    initBootProcess
#  SYNOPSIS
#    function initBootProcess() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function initBootProcess() {

  # copied from redhat /etc/init.d/functions
  TEXTDOMAIN=initscripts

  # Make sure umask is sane
  umask 022

  # Get a sane screen width
  [ -z "${COLUMNS:-}" ] && COLUMNS=80

  [ -z "${CONSOLETYPE:-}" ] && CONSOLETYPE="`/sbin/consoletype`"

  if [ -f /etc/sysconfig/i18n -a -z "${NOLOCALE:-}" ] ; then
    . /etc/sysconfig/i18n
    if [ "$CONSOLETYPE" != "pty" ]; then
      case "${LANG:-}" in
        ja_JP*|ko_KR*|zh_CN*|zh_TW*|bn_*|bd_*|pa_*|hi_*|ta_*|gu_*)
          export LC_MESSAGES=en_US
          export LANG
        ;;
      *)
        export LANG
        ;;
      esac
    else
      [ -n "$LC_MESSAGES" ] && export LC_MESSAGES
      export LANG
    fi
  fi

  # Read in our configuration
  if [ -z "${BOOTUP:-}" ]; then
#    if [ -f /etc/sysconfig/init ]; then
#      . /etc/sysconfig/init
#    else
#      # This all seem confusing? Look in /etc/sysconfig/init,
#      # or in /usr/doc/initscripts-*/sysconfig.txt
#      BOOTUP=color
#      RES_COL=60
#      MOVE_TO_COL="echo -en \\033[${RES_COL}G"
#      SETCOLOR_SUCCESS="echo -en \\033[1;32m"
#      SETCOLOR_FAILURE="echo -en \\033[1;31m"
#      SETCOLOR_WARNING="echo -en \\033[1;33m"
#      SETCOLOR_NORMAL="echo -en \\033[0;39m"
#      LOGLEVEL=1
#    fi
#    if [ "$CONSOLETYPE" = "serial" ]; then
      BOOTUP=serial
      MOVE_TO_COL=
      SETCOLOR_SUCCESS=
      SETCOLOR_FAILURE=
      SETCOLOR_WARNING=
      SETCOLOR_NORMAL=
#    fi
  fi

  if [ "${BOOTUP:-}" != "verbose" ]; then
    INITLOG_ARGS="-q"
  else
    INITLOG_ARGS=
  fi
  date=`/bin/date`
    
  echo_local "***********************************"
  echo_local "Starting GFS Shared Root for $HOSTNAME"
  echo_local "Date: $date"
  echo_local "***********************************"
    
  echo_local_debug "*****************************"
  echo_local -n "Mounting Proc-FS"
  exec_local /bin/mount -t proc proc /proc
  return_code

  echo_local -n "Mounting Sys-FS"
  exec_local /bin/mount -t sysfs none /sys
  return_code

  echo_local_debug "/proc/cmdline"
  exec_local_debug cat /proc/cmdline

  if [ ! -e /mnt/newroot ]; then
    mkdir -p /mnt/newroot
  fi
  return $?
}
#************ initBootProcess 

#****f* boot-lib.sh/start_service
#  NAME
#    start_service
#  SYNOPSIS
#    function start_service(service, chroot)
#  DESCRIPTION
#    This function starts the given service in a chroot environment per default
#    If no_chroot is given as param the chroot is skipped
#  IDEAS
#  SOURCE
#
function start_service {
#  if [ -n "$debug" ]; then set -x; fi
  [ -d "$1" ] && chroot_dir=$1 && shift
  service=$1
  service_name=$(basename $service)
  shift

  service_dirs=$(cat /etc/${service_name}_dirs.list 2>/dev/null)
  service_mv_files=$(cat /etc/${service_name}_mv_files.list 2>/dev/null)
  service_cp_files=$(cat /etc/${service_name}_cp_files.list 2>/dev/null)
#  echo_local_debug "Service($service_name)dirs: "$service_dirs
#  echo_local_debug "Service($service_name)cp: "$service_cp_files
#  echo_local_debug "Service($service_name)mv: "$service_mv_files

  if [ -z "$service" ]; then
    error_local "start_service: No service given"
    return -1
  fi
  echo_local -n "Starting service $service_name"
  if [ -n "$1" ] && [ "$1" = "no_chroot" ]; then
    shift
    $($service $*)
  else
    [ -z "$chroot_dir" ] && chroot_dir="/var/lib/${service_name}"
    echo_local -n "service=$service_name..build chroot ($chroot_dir).."
    [ -d $chroot_dir ] || mkdir -p $chroot_dir
    for dir in $service_dirs; do
      [ -d $chroot_dir/$dir ] || mkdir -p $chroot_dir/$dir 2>/dev/null
    done
    echo_local -n ".(dir)."
    for file in $service_cp_files; do
      [ -d $(dirname $chroot_dir/$file) ] || mkdir -p $(dirname $chroot_dir/$file)
      [ -e $chroot_dir/$file ] || cp -af $file $chroot_dir/$file 2>/dev/null
    done
    echo_local -n ".(cp)."
    for file in $service_mv_files; do
      [ -d $(dirname $chroot_dir/$file) ] || mkdir -p $(dirname $chroot_dir/$file)
      [ -e $chroot_dir/$file ] || mv $file $chroot_dir/$file #2>/dev/null
      [ -e $file ] || ln -sf $chroot_dir/$file $file #2>/dev/null
    done
    echo_local -n ".(mv)."
#    for file in /usr/kerberos/lib/*; do
#      [ -e /usr/lib/$(basename $file) ] || ln -sf $file /usr/lib/$(basename $file) 2>/dev/null
#      [ -e ${chroot_dir}/usr/lib/$(basename $file) ] || ln -sf $file ${chroot_dir}/usr/lib/$(basename $file) 2>/dev/null
#    done

    echo_local -n "..$service.."
    /usr/sbin/chroot $chroot_dir $service $* || 
    ( echo_local -n "chroot not worked failing back.." && $service $*)
    return_code $?
  fi
#  if [ -n "$debug" ]; then set +x; fi
}
#************ start_service 

#****f* boot-lib.sh/switchRoot
#  NAME
#    switchRoot
#  SYNOPSIS
#    function switchRoot(newroot, initrdroot) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function switchRoot() {
  local new_root=$1
  if [ -z "$new_root" ]; then
     new_root="/mnt/newroot"
  fi

  echo_local_debug "**********************************************************************"
  cd ${new_root}

  pivot_root=initrd
  echo_local -n "Pivot-Rooting... (pwd: "$(pwd)")"
  [ ! -d $pivot_root ] && mkdir -p $pivot_root
  exec_local /sbin/pivot_root . $pivot_root
  return_code
  critical=$?
  return $critical
}
#************ switchRoot 

#****f* boot-lib.sh/mountDev
#  NAME
#    mountDev
#  SYNOPSIS
#    function mountDev {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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
#************ mountDev 

#****f* boot-lib.sh/createTemp
#  NAME
#    createTemp
#  SYNOPSIS
#    function createTemp {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function createTemp {
    local device=$1
    mkfs.ext2 -L tmp $device
    mount $device ./tmp
    chmod -R a+t,a+rwX ./tmp/. ./tmp/*
}

#************ createTemp 
#****f* boot-lib.sh/stop_service
#  NAME
#    stop_service
#  SYNOPSIS
#    function stop_service {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function stop_service {
  local service_name=$1
  local other_root=$2
  if [ -f ${other_root}/var/run/${service_name}.pid ]; then
    exec_local kill $(cat ${other_root}/var/run/${service_name}.pid)
  fi
}

#************ stop_service 
#****f* boot-lib.sh/clean_initrd
#  NAME
#    clean_initrd
#  SYNOPSIS
#    function clean_initrd() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
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

#************ clean_initrd 
#****f* boot-lib.sh/ipaddress_from_name
#  NAME
#    ipaddress_from_name
#  SYNOPSIS
#    function ipaddress_from_name() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function ipaddress_from_name() {
   gfsip=`/bin/nslookup ${name} | /bin/grep -A1 Name: | /bin/grep Address: | /bin/sed -e "s/\\W*Address:\\W*//"`
}
#************ ipaddress_from_name 
#****f* boot-lib.sh/ipaddress_from_dev
#  NAME
#    ipaddress_from_dev
#  SYNOPSIS
#    function ipaddress_from_dev() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function ipaddress_from_dev() {
   gfsip=`/sbin/ifconfig ${netdev} | /bin/grep "inet addr:" | /bin/sed -e "s/\\W*inet\\Waddr://" | /bin/sed -e "s/\\W*Bcast:.*$//"`
}
#************ ipaddress_from_dev 
#****f* boot-lib.sh/echo_out
#  NAME
#    echo_out
#  SYNOPSIS
#    function echo_out() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function echo_out() {
    echo ${*:0:$#-1} "${*:$#}" >&3
}

#************ echo_out 
#****f* boot-lib.sh/echo_local
#  NAME
#    echo_local
#  SYNOPSIS
#    function echo_local() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function echo_local() {
   echo ${*:0:$#-1} "${*:$#}"
   echo ${*:0:$#-1} "${*:$#}" >&3
   echo ${*:0:$#-1} "${*:$#}" >&5
#   echo ${*:0:$#-1} "${*:$#}" >> $bootlog
#   [ -n "$logger" ] && echo ${*:0:$#-1} "${*:$#}" | $logger
}
#************ echo_local 
#****f* boot-lib.sh/echo_local_debug
#  NAME
#    echo_local_debug
#  SYNOPSIS
#    function echo_local_debug() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function echo_local_debug() {
   if [ ! -z "$debug" ]; then
     echo ${*:0:$#-1} "${*:$#}"
     echo ${*:0:$#-1} "${*:$#}" >&3
     echo ${*:0:$#-1} "${*:$#}" >&5
#     echo ${*:0:$#-1} "${*:$#}" >> $bootlog
#     [ -n "$logger" ] && echo ${*:0:$#-1} "${*:$#}" | $logger
   fi
}
#************ echo_local_debug 
#****f* boot-lib.sh/error_out
#  NAME
#    error_out
#  SYNOPSIS
#    function error_out() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function error_out() {
    echo ${*:0:$#-1} "${*:$#}" >&4
    echo ${*:0:$#-1} "${*:$#}" >&5
}
#************ error_out 
#****f* boot-lib.sh/error_local
#  NAME
#    error_local
#  SYNOPSIS
#    function error_local() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function error_local() {
   echo ${*:0:$#-1} "${*:$#}" >&2
   echo ${*:0:$#-1} "${*:$#}" >&4
   echo ${*:0:$#-1} "${*:$#}" >&5
#   echo ${*:0:$#-1} "${*:$#}" >> $bootlog
#   [ -n "$logger" ] && echo ${*:0:$#-1} "${*:$#}" | $logger
}
#************ error_local 
#****f* boot-lib.sh/error_local_debug
#  NAME
#    error_local_debug
#  SYNOPSIS
#    function error_local_debug() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function error_local_debug() {
   if [ ! -z "$debug" ]; then
     echo ${*:0:$#-1} "${*:$#}" >&2
     echo ${*:0:$#-1} "${*:$#}" >&4
     echo ${*:0:$#-1} "${*:$#}" >&5
#     echo ${*:0:$#-1} "${*:$#}" >> $bootlog
#     [ -n "$logger" ] && echo ${*:0:$#-1} "${*:$#}" | $logger
   fi
}

#************ error_local_debug 

#****f* boot-lib.sh/exec_local
#  NAME
#    exec_local
#  SYNOPSIS
#    function exec_local() {
#  DESCRIPTION
#    execs the given parameters in a subshell and returns the 
#    error_code
#  IDEAS
#  SOURCE
#
function exec_local() {
  $*
  return_c=$?
  if [ ! -z "$debug" ]; then 
    echo "cmd: $*"
    echo "$output"
  fi
#  echo "cmd: $*" >> $bootlog
#  echo "$output" >> $bootlog
  return $return_c
}
#************ exec_local 

#****f* boot-lib.sh/exec_local_debug
#  NAME
#    exec_local_debug
#  SYNOPSIS
#    function exec_local_debug() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function exec_local_debug() {
  if [ ! -z "$debug" ]; then
    exec_local $*
  fi
}
#************ exec_local_debug 

#****f* boot-lib.sh/return_code
#  NAME
#    return_code
#  SYNOPSIS
#    function return_code() {
#  DESCRIPTION
#    Displays the actual return code. Either from $1 if given or from $?
#  SOURCE
#
function return_code {
  if [ -n "$1" ]; then
    return_c=$1
  fi
  if [ -n "$return_c" ] && [ $return_c -eq 0 ]; then
    success
  else
    failure
  fi
  local code=$return_c
  return_c=
  return $code
}
#************ return_code 

#****f* boot-lib.sh/return_code_warning
#  NAME
#    return_code_warning
#  SYNOPSIS
#    function return_code_warning() {
#  DESCRIPTION
#    Displays the actual return code. Warning instead of failed.
#    Either from $1 if given or from $?
#  SOURCE
#
function return_code_warning() {
  if [ -z "$1" ]; then
    return_c=$?
  else
    return_c=$1
  fi
  if [ $return_c -eq 0 ]; then
    success
  else
    warning
  fi
}
#************ return_code_warning 

#****f* boot-lib.sh/return_code_passed
#  NAME
#    return_code_passed
#  SYNOPSIS
#    function return_code_passed() {
#  DESCRIPTION
#    Displays the actual return code. Warning instead of failed.
#    Either from $1 if given or from $?
#  SOURCE
#
function return_code_passed() {
  if [ -z "$1" ]; then
    return_c=$?
  else
    return_c=$1
  fi
  if [ $return_c -eq 0 ]; then
    success
  else
    warning
  fi
}
#************ return_code_passed 

#****f* boot-lib.sh/success
#  NAME
#    success
#  SYNOPSIS
#    function success()
#  DESCRIPTION
#    returns formated OK
#  SOURCE
function success {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "[  "
  echo -n "[  " >&3
  echo -n "[  " >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
  echo -n "OK"
  echo -n "OK" >&3
  echo -n "OK" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "  ]"
  echo "  ]" >&3
  echo "  ]" >&5
#  echo -ne "\r"
#  echo -ne "\r" >&3
  return 0
}
#********** success 

#****f* boot-lib.sh/failure
#  NAME
#    failure
#  SYNOPSIS
#    function failure()
#  DESCRIPTION
#    returns formated FAILURE
#  SOURCE
function failure {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  echo -n "[" >&3
  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
  echo -n "FAILED"
  echo -n "FAILED" >&3
  echo -n "FAILED" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
#  echo -ne "\r"
  echo "]" >&3
  echo "]" >&5
#  echo -ne "\r" >&3
  return 1
}
#********** warning 

#****f* boot-lib.sh/warning
#  NAME
#    warning
#  SYNOPSIS
#    function warning()
#  DESCRIPTION
#    returns formated WARNING
#  SOURCE
function warning {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  echo -n "[" >&3
  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
  echo -n "WARNING"
  echo -n "WARNING" >&3
  echo -n "WARNING" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
#  echo -ne "\r"
  echo "]" >&3
  echo "]" >&5
#  echo -ne "\r" >&3
  return 1
}
#********** warning 

#****f* boot-lib.sh/passed
#  NAME
#    passed
#  SYNOPSIS
#    function passed()
#  DESCRIPTION
#    returns formated PASSED
#  SOURCE
function passed {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  echo -n "[" >&3
  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
  echo -n "PASSED"
  echo -n "PASSED" >&3
  echo -n "PASSED" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
#  echo -ne "\r"
  echo "]" >&3
  echo "]" >&5
#  echo -ne "\r" >&3
  return 1
}
#********** passed 

# $Log: boot-lib.sh,v $
# Revision 1.30  2006-05-07 11:37:15  marc
# major change to version 1.0.
# Complete redesign.
#
# Revision 1.29  2006/05/03 12:49:16  marc
# added documentation
#
# Revision 1.28  2006/04/13 18:48:59  marc
# checking an error on restart_cluster_services and not removing files from initrd
#
# Revision 1.27  2006/04/08 18:03:43  mark
# added support for multiple scsi_adapter
#
# Revision 1.26  2006/02/16 13:58:50  marc
# pivot_root and chroot changes
# newroot variable added
#
# Revision 1.25  2006/01/28 15:09:13  marc
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
