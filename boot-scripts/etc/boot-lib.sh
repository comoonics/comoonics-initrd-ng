#
# $Id: boot-lib.sh,v 1.63 2008-08-14 13:34:58 marc Exp $
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
#****h* comoonics-bootimage/boot-lib.sh
#  NAME
#    boot-lib.sh
#    $id$
#  DESCRIPTION
#*******


#LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/lib/i686:/usr/lib"
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH #LD_LIBRARY_PATH

# Binaries
STAT="/usr/bin/stat"
COPY="/bin/cp"
MOVE="/bin/mv"
MKDIR="/bin/mkdir"

step_timeout=10
bootlog="/var/log/comoonics-boot.log"
error_code_file="/var/error_code"
init_cmd_file="/var/init_cmd"
init_chroot_file="/var/init_chroot_file"
# the disk where the bootlog should be written to (default /dev/fd0).
diskdev="/dev/fd0"
[ -e /usr/bin/logger ] && logger="/usr/bin/logger -t com-bootlog"
modules_conf="/etc/modprobe.conf"

# Default init cmd is bash
init_cmd="/bin/bash"

# TODO: consolidate mount_point , new_root and newroot to newroot
newroot="/mnt/newroot"
#mount_point="/mnt/newroot"

# The comoonics buildfile
build_file="/etc/comoonics-build.txt"

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
    # FIXME: remove commented lines
    #if [ -n "$error_code" ] && [ $error_code -eq 2 ]; then
    #    echo_local "Userquit falling back to bash.."
	#exec 5>&1 6>&2 1>/dev/console 2>/dev/console
    #    /bin/bash
	#exec 1>&5 2>&6
    #else
	#echo_local "Writing $init_cmd $newroot => $init_cmd_file"
	#echo "$init_cmd" > $init_cmd_file
	#echo "$newroot" > $init_chroot_file
	exit $error_code
    #fi
}
#************ exit_linuxrc

#****f* boot-lib.sh/step
#  NAME
#    step
#  SYNOPSIS
#    function step( info ) {
#  MODIFICATION HISTORY
#  IDEAS
#    Modify or debug a running skript
#  DESCRIPTION
#    If stepmode step asks for input.
#  SOURCE
#
function step() {
   local __the_step=""
   if [ ! -z "$stepmode" ]; then
   	 echo $1
     echo -n "Press <RETURN> to continue (timeout in $step_timeout secs) [quit|break|continue]"
     read -t$step_timeout __the_step
     case "$__the_step" in
       "quit")
         exit_linuxrc 2
         ;;
       "continue")
         stepmode=""
         ;;
       "break")
         echo_local "Break detected forking a shell"
         /bin/sh &>/dev/console
         echo_local "Back to work.."
         ;;
     esac
     if [ -z "$__the_step" ]; then
       echo
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
   echo -n "$out"
   if [ -z "$out" ]; then
       return 1
   else
       return 0
   fi
}
#************ getBootParm

#****f* boot-lib.sh/getParm
#  NAME
#    getParm
#  SYNOPSIS
#    function getParm(param, [default])
#  DESCRIPTION
#    Gets the given parameter from the bootloader command line. If not
#    found default or the empty string is returned.
#  SOURCE
#
function getParm() {
   cmdline="$1"
   parm="$2"
   echo $cmdline | awk -v pos=$parm 'BEGIN { FS=":"; }{ printf "%s", $pos; }'
}
#************ getParm

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
	if [ -e /etc/redhat-release ]; then
    	if cat /etc/redhat-release | grep -i "release 4" &> /dev/null; then
     		echo "rhel4"
   	 	elif cat /etc/redhat-release | grep -i "release 5" &> /dev/null; then
   	 		echo "rhel5"
    	fi
    elif [ -e /etc/SuSE-release ]; then
        awk -vdistribution=sles '/VERSION[[:space:]]*=[[:space:]]*[[:digit:]]+/ { print distribution$3;}' /etc/SuSE-release
	else
		echo "unknown"
    	return 2
   	fi
}
#**** getDistribution

#****f* boot-lib.sh/getParameter
#  NAME
#    getParameterValue
#  SYNOPSIS
#    function getParameter(name, default) {
#  DESCRIPTION
#    returns a parameter
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getParameter() {
	local repository="configparams"
	local name=$1
	local default=$2
	local ret=""
	
	# check if parameter is already in repository
	if repository_has_key $repository $name; then
		repository_get_value $repository $name
		return 0
	fi
	# first check for a boot parameter
	if ret=$(getBootParm $name); then
		repository_store_value $repository $name $ret
		echo $ret
		return 0
	fi
	# if we cannot find this one, try with a "com-"
	if ret=$(getBootParm com-$name); then
		repository_store_value $repository $name $ret
		echo $ret
		return 0
	fi
	# then we try to find a method to query the cluster configuration
	if ret=$(getClusterParameter $name); then
		repository_store_value $repository $name $ret
		echo $ret
		return 0
	fi
	echo $default
	return 1		
		
}
#************ getParameter

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
    echo -n ":"
    getBootParm com-step
    echo -n ":"
    getBootParm mountopt
    echo -n ":"
    getBootParm tmpfix
    echo -n ":"
    getBootParm scsifailover
    echo -n ":"
    getBootParm com-dstep
    echo -n ":"
    getBootParm nousb
}
#************ getBootParameters

#****f* boot-lib.sh/welcome
#  NAME
#    welcome
#  SYNOPSIS
#    function welcome() {
#  MODIFICATION HISTORY
#  IDEAS
#    Says hello distribution indenpendent
#  SOURCE
#
function welcome() {
	local _distro=$1
	typeset -f ${_distro}_welcome >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		${_distro}_welcome
	else
        echo -en $"\t\tWelcome to "
		if [ -e /etc/redhat-release ]; then
           if LC_ALL=C grep -q "Red Hat" /etc/redhat-release ; then
              [ "$BOOTUP" = "color" ] && echo -en "\\033[0;31m"
              echo -en "Red Hat"
              [ "$BOOTUP" = "color" ] && echo -en "\\033[0;39m"
              PRODUCT=`sed "s/Red Hat \(.*\) release.*/\1/" /etc/redhat-release`
           elif LC_ALL=C grep -q "Fedora" /etc/redhat-release ; then
              [ "$BOOTUP" = "color" ] && echo -en "\\033[0;31m"
              echo -en "Fedora"
              [ "$BOOTUP" = "color" ] && echo -en "\\033[0;39m"
              PRODUCT=`sed "s/Fedora \(.*\) release.*/\1/" /etc/redhat-release`
           else
              PRODUCT=`sed "s/ release.*//g" /etc/redhat-release`
           fi
        else
           PRODUCT=$(cat $(find /etc -name "*release" -not -name "lsb-release" -not -name "comoonics-release") | head -1)
        fi
        echo "$PRODUCT"
	fi	
}
#****** welcome
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
  initEnv
  date=`/bin/date`


  echo_local "***********************************"
  # Print a text banner.
  release=$(cat /etc/comoonics-release)
  echo_local -en $"\t\tWelcome to "
  [ "$BOOTUP" = "color" ] && echo -en "\\033[0;34m"
  echo_local $release
  [ "$BOOTUP" = "color" ] && echo -en "\\033[0;39m"
  echo_local "Starting GFS Shared Root"
  echo_local "Date: $date"
  echo_local "***********************************"

  echo_local_debug "*****************************"
  echo_local -n "Mounting Proc-FS"
  exec_local /bin/mount -t proc proc /proc
  return_code

  echo_local -n "Mounting Sys-FS"
  exec_local /bin/mount -t sysfs none /sys
  return_code

  echo_local -n "Mounting Dev"
  exec_local dev_start
  return_code

  echo_local_debug "/proc/cmdline"
  exec_local_debug cat /proc/cmdline

  if [ ! -d /tmp ]; then
  	mkdir /tmp
  fi

  if [ ! -e /mnt/newroot ]; then
    mkdir -p /mnt/newroot
  fi
  return $?
}
#************ initBootProcess


#****f* boot-lib.sh/start_service_chroot
#  NAME
#    start_service_chroot
#  SYNOPSIS
#    function start_service_chroot(chrootdir, service)
#  DESCRIPTION
#    This function starts the given service in a chroot path
#  IDEAS
#    This function replaces start_service
#  SOURCE
#
function start_service_chroot() {
	chroot_dir=$1
	shift
	service_name=$1
	shift
	echo_local -n "Starting service $service_name"
	exec_local /usr/sbin/chroot $chroot_dir $service_name $*
	return_code
}
#********start_service_chroot

#****f* boot-lib.sh/start_service
#  NAME
#    start_service
#  SYNOPSIS
#    function start_service([chrootdir], service, [nostart], [no_chroot/nochroot], [dir=/etc], [onlycopy], [nofailback])
#  DESCRIPTION
#    This function starts the given service in a chroot environment per default
#    If no_chroot is given as param the chroot is skipped
#  IDEAS
#    deprecated in 1.3
#  SOURCE
#
function start_service {
#  if [ -n "$debug" ]; then set -x; fi
  nochroot=
  onlycopy=
  nofailback=
  dir=/etc
  [ -d "$1" ] && chroot_dir=$1 && shift
  service=$1
  shift
  aservice=( $service )
  service_name=$(basename ${aservice[0]})
  [ -n "$1" ] && [ "$1" = "no_chroot" ] && nochroot=1 && shift
  [ -n "$1" ] && [ -d $1 ] && dir=$1 && shift
  [ -n "$1" ] && [ "$1" = "onlycopy" ] && onlycopy=$1 && shift
  [ -n "$1" ] && [ "$1" = "nofailback" ] && nofailback=$1 && shift
  [ -n "$1" ] && [ "$1" = "nostart" ] && nostart=1

  service_dirs=$(cat ${dir}/${service_name}_dirs.list 2>/dev/null)
  if [ -z "$onlycopy" ]; then
  	 service_mv_files=$(cat ${dir}/${service_name}_mv_files.list 2>/dev/null)
     service_cp_files=$(cat ${dir}/${service_name}_cp_files.list 2>/dev/null)
  else
     service_cp_files=$(cat ${dir}/${service_name}_cp_files.list ${dir}/${service_name}_mv_files.list 2>/dev/null)
     service_mv_files=""
  fi
#  echo_local_debug "Service($service_name)dirs: "$service_dirs
#  echo_local_debug "Service($service_name)cp: "$service_cp_files
#  echo_local_debug "Service($service_name)mv: "$service_mv_files

  if [ -z "$service" ]; then
    error_local "start_service: No service given"
    return -1
  fi
  echo_local -n "Starting service $service_name"
  if [ -n "$nochroot" ]; then
    $($service $*)
    return_code $?
  else
    [ -z "$chroot_dir" ] && chroot_dir="/var/lib/${service_name}"
    echo_local -n "service=$service_name..build chroot ($chroot_dir).."
    [ -d $chroot_dir ] || mkdir -p $chroot_dir
    for dir in $service_dirs; do
      [ -d $chroot_dir/$dir ] || mkdir -p $chroot_dir/$dir 2>/dev/null
    done
    echo_local -n ".(dir)."
    for file in $service_cp_files; do
      cp_file $file $chroot_dir/$file 2>/dev/null
    done
    echo_local -n ".(cp)."
    for file in $service_mv_files; do
      [ -d $(dirname $chroot_dir/$file) ] || mkdir -p $(dirname $chroot_dir/$file) 2>/dev/null
#      [ -e $chroot_dir/$file ] || /bin/mv $file $chroot_dir/$file 2>/dev/null
      /bin/mv $file $chroot_dir/$file 2>/dev/null
      [ -e $file ] || ln -sf $chroot_dir/$file $file 2>/dev/null
    done
    echo_local -n ".(mv)."
#    for file in /usr/kerberos/lib/*; do
#      [ -e /usr/lib/$(basename $file) ] || ln -sf $file /usr/lib/$(basename $file) 2>/dev/null
#      [ -e ${chroot_dir}/usr/lib/$(basename $file) ] || ln -sf $file ${chroot_dir}/usr/lib/$(basename $file) 2>/dev/null
#    done

	if [ -z "$nostart" ]; then
      echo_local -n "..$service.."
      /usr/sbin/chroot $chroot_dir $service $*
      if [ $? -ne 0 ] && [ -z "$nofailback" ]; then
        echo_local -n "chroot not worked failing back.." && $service $*
      fi
	fi
    return_code $?
  fi
#  if [ -n "$debug" ]; then set +x; fi
}
#************ start_service

#****f* boot-lib.sh/move_chroot
#  NAME
#    move chroot environment
#  SYNOPSIS
#    function move_chroot(chroot_path, new_chroot_path) {
#  MODIFICATION HISTORY
#  USAGE
#
#  IDEAS
#
#  SOURCE
#
function move_chroot () {
  local chroot_mount=$1
  local new_chroot_mount=$2

  exec_local mkdir -p $new_chroot_mount
  exec_local /bin/mount --move $chroot_mount $new_chroot_mount
}
#************ move_chroot

#****f* boot-lib.sh/prepare_newroot
#  NAME
#    prepare_newroot
#  SYNOPSIS
#    function prepare_newroot(newroot) {
#  MODIFICATION HISTORY
#  USAGE
#
#  IDEAS
#
#  SOURCE
#
function prepare_newroot() {
	exec_local mount -t proc proc $1/proc
}
#************** prepare_newroot

#****f* boot-lib.sh/build_chroot
#  NAME
#    move chroot environment
#  SYNOPSIS
#    function build_chroot(clusterconf, nodename) {
#  MODIFICATION HISTORY
#  USAGE
#
#  IDEAS
#
#  SOURCE
#
function build_chroot () {
	local cluster_conf=$1
	local nodename=$2
	local chroot_fstype
	local chroot_dev
	local chroot_mount
	local chroot_path
	local chroot_options

	# method1: read file /etc/sysconfig/comoonics-chroot
	if [ -e  /etc/sysconfig/comoonics-chroot ]; then
		. /etc/sysconfig/comoonics-chroot
	# method2: read all information from cluster.conf
	# --if not given: uses default values
	else
		# Filesystem type for the chroot device
		chroot_fstype=$(cc_get_chroot_fstype $cluster_conf $nodename)
		# chroot device name
		chroot_dev=$(cc_get_chroot_device $cluster_conf $nodename)
		# Mountpoint for the chroot device
		chroot_mount=$(cc_get_chroot_mountpoint $cluster_conf $nodename)
		# Path where the chroot environment should be build
		chroot_path=$(cc_get_chroot_dir $cluster_conf $nodename)
		# Mount options for the chroot device
		chroot_options=$(cc_get_chroot_mountopts $cluster_conf $nodename)
	fi

	echo_out -n "Creating chroot environment"
	exec_local mkdir -p $chroot_mount
	exec_local /bin/mount -t $chroot_fstype -o $chroot_options $chroot_dev $chroot_mount
	return_code $? >/dev/null
	# method3 fallback to tmpfs
	if [ $? -ne 0 ]; then
		echo_out -n "Mounting chroot failed. Using default values"
		#Fallback values
		# Filesystem type for the chroot device
		chroot_fstype="tmpfs"
		# chroot device name
		chroot_dev="none"
		# Mountpoint for the chroot device
		chroot_mount=$DFLT_CHROOT_MOUNT
		# Path where the chroot environment should be build
		chroot_path=$DFLT_CHROOT_PATH
		# Mount options for the chroot device
		chroot_options="defaults"
		exec_local mkdir -p $chroot_mount
		exec_local /bin/mount -t $chroot_fstype -o $chroot_options $chroot_dev $chroot_mount
		return_code >/dev/null
	fi
	create_chroot "/" $chroot_path
	echo "$chroot_mount $chroot_path"
}


#****f* boot-lib.sh/switchRoot
#  NAME
#    switchRoot has to be called from linuxrc at the end of the initrd instructions
#  SYNOPSIS
#    function switchRoot(newroot, initrdroot) {
#  MODIFICATION HISTORY
#  USAGE
#  switchRoot
#  IDEAS
#
#  SOURCE
#
function switchRoot() {
  local skipfiles="rm mount chroot find"
  local newroot=$1
  local cominit="/usr/comoonics/sbin/init"
  if [ -z "$new_root" ]; then
     newroot="/mnt/newroot"
  fi

  echo "**********************************************************************"
  echo " comoonics generic switchroot"

  #get init_cmd from /proc
  if [ -e "$newroot/$cominit" ]; then
  	init_cmd="$cominit $(cat /proc/cmdline)"
  	echo_local_debug "found init in $cominit"
  else
  	init_cmd="/sbin/init $(cat /proc/cmdline)"
  fi
  # clean up
  echo "Cleaning up..."
  #umount /dev
  [ -e /proc/bus/usb ] && umount /proc/bus/usb
  umount /proc
  umount /sys


  #if type -t ${distribution}_switchRoot > /dev/null; then
  #	echo_local_debug "calling ${distribution}_switchRoot ${new_root}"
  #	exec ${distribution}_switchRoot ${new_root}

  # this returns a comand to delete all unused files.
  # TODO: directories are not removed. Add functionality to remove empty directories.
  # CAUTION: Do NOT remove /mnt/newroot ;-)
  skipfiles=$(for file in $skipfiles; do which $file; done)
  skipfiles=$(for file in $skipfiles; do get_dependent_files $file; which $file; done | sort -u)
  skipfiles="$skipfiles /dev/console"
  skipfiles=$(echo $skipfiles | sort -u | sed 's/ /" -o -regex "/g')
  cmd=$(echo find / -xdev ! \\\( -regex \"$skipfiles\" \\\) -exec 'rm {}' '\;')

  eval $cmd > /dev/null 2>&1

  cd ${newroot}
  # TODO
  /bin/mount --move . /
  exec chroot . $init_cmd </dev/console >/dev/console 2>&1
}
#************ switchRoot

#****f* create-gfs-initrd-lib.sh/create_builddate_file
#  NAME
#    create_builddate_file
#  SYNOPSIS
#    function create_builddate_file() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function create_builddate_file {
	local bd_file=$1
	# patching build file
	if [ -n "$bd_file" ]; then
		echo_local -n "builddate_file"
    	echo "Build Date: "$(date) >> $bd_file
    	return_code $?
	else
	    return_code 1
	fi
}
#************ create_bulddate_file

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

#****f* boot-lib.sh/restart_init
#  NAME
#    restart_init
#  SYNOPSIS
#    function restart_init {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function restart_init {
	exec_local init u
}
#************ restart_init

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
	local procs="udevd"
	echo_local_debug "Sending unnecessary processes the KILL signal"
	for p in $procs; do
		killall $p &> /dev/null
	done
	sleep 3
	echo_local_debug "Sending unnecessary processes the TERM signal"
	for p in $procs; do
		killall -9 $p &> /dev/null
	done

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
#   echo ${*:0:$#-1} "${*:$#}" >&5
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
#     echo ${*:0:$#-1} "${*:$#}" >&5
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
    echo ${*:0:$#-1} "${*:$#}" >&2
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
#   echo ${*:0:$#-1} "${*:$#}" >&5
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
#     echo ${*:0:$#-1} "${*:$#}" >&5
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
#
#  SOURCE
#
function exec_local() {
  do_exec=1
  if [ -n "$dstepmode" ]; then
  	echo -n "$* (Y|n|c)? " >&2
  	read dstep_ans
  	[ "$dstep_ans" == "n" ] && do_exec=0
  	[ "$dstep_ans" == "c" ] && dstepmode=""
  fi
  if [ $do_exec == 1 ]; then
  	output=$($*)
  else
  	output="skipped"
  fi
  return_c=$?
  if [ ! -z "$debug" ]; then
    echo "cmd: $*" >&3
    echo "OUTPUT: $output" >&3
  fi
#  echo "cmd: $*" >> $bootlog
  echo -n "$output"
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

#****f* boot-lib.sh/exec_local_stabilized
#  NAME
#    exec_local_stabilized
#  SYNOPSIS
#    function exec_local_stabilized(reps, sleeptime, command ...) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
#  used to call a function until it succeded

function exec_local_stabilized() {
	reps=$1
	stime=$2
 	shift 2
	ret=1

 	for i in $(seq $reps); do
 		if [ ! -z "$debug" ]; then
 			echo "start_service_chroot run: $i, sleeptime: $stime" >&3
 		fi
   		output=$($exec_local $*) 
   		if [ $? -eq 0 ]; then
   			ret=0
   			break
   		fi 
   		sleep $stime
 	done	
 	echo $output
 	return $ret
}
#************ exec_local_stabilized


# $Log: boot-lib.sh,v $
# Revision 1.63  2008-08-14 13:34:58  marc
# - made _stepmode local
# - added welcome
# - changed order of umount because of problems with nfs
#
# Revision 1.62  2008/07/15 12:50:24  marc
# - changed getDistribution to also support Novell/SuSE LE
# - fixed Bug#242
#
# Revision 1.61  2008/07/03 12:44:13  mark
# add new method getParameter
#
# Revision 1.60  2008/05/28 10:12:27  mark
# added exec_local_stabilized
# fix for bz 193
#
# Revision 1.59  2008/03/18 17:40:00  marc
# - fixed bug for not detecting failover in all cases.
#
# Revision 1.58  2008/01/24 13:27:17  marc
# - BUG#178 nousb parameter can be specified (added bootparm)
#
# Revision 1.57  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.56  2007/10/18 08:04:07  mark
# add mountopts debug message
#
# Revision 1.55  2007/10/10 22:48:08  mark
# fixes BZ139
#
# Revision 1.54  2007/10/09 16:46:45  mark
# added prepare_newroot
#
# Revision 1.53  2007/10/09 15:07:37  marc
# - beautified
#
# Revision 1.52  2007/10/08 15:17:24  mark
# made create_chroot distro dependent
#
# Revision 1.51  2007/10/05 14:33:38  mark
# bug fix
#
# Revision 1.50  2007/10/05 09:04:26  mark
# added restart_init
#
# Revision 1.49  2007/10/02 12:13:49  marc
# - fixed BUG 127, chroot would not work because nodename not set correctly
# - fixed BUG 128, old chroot would not be overwritten as expected
#
# Revision 1.48  2007/10/02 11:52:25  mark
# copy /dev instead of --bind mount
#
# Revision 1.47  2007/09/26 11:39:59  mark
# fixes typo
#
# Revision 1.46  2007/09/21 15:35:56  mark
# clean up /var/run
#
# Revision 1.45  2007/09/18 10:10:05  mark
# modified clean_initrd as it was too aggressive
#
# Revision 1.44  2007/09/07 07:59:45  mark
# added rhel5 distro detection
# replaced clean_initrd
#
# Revision 1.43  2007/08/07 16:10:03  mark
# bug fix in chroot_path environment
#
# Revision 1.42  2007/08/06 15:50:11  mark
# reorganized libraries
# added methods for chroot management
# fits for bootimage release 1.3
#
# Revision 1.41  2007/05/23 09:14:43  mark
# added some fancy output
#
# Revision 1.40  2007/03/09 18:03:11  mark
# added nash like switchRoot support
#
# Revision 1.39  2007/02/09 11:03:59  marc
# added create_builddate_file function
#
# Revision 1.38  2007/01/19 13:38:53  mark
# exec_local used $dstepmode (Y|n|c)
# exit_linuxrc creates 2 files for init
#
# Revision 1.37  2006/12/04 17:39:23  marc
# enhanced stepmode
#
# Revision 1.36  2006/10/06 08:34:15  marc
# added some bins as variables
#
# Revision 1.35  2006/08/28 16:06:45  marc
# bugfixes
# new version of start_service
#
# Revision 1.34  2006/07/13 11:37:02  marc
# added dev mount
#
# Revision 1.33  2006/06/19 15:55:45  marc
# added device mapper support
#
# Revision 1.32  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.31  2006/05/12 13:02:41  marc
# First stable Version for 1.0.
#
# Revision 1.30  2006/05/07 11:37:15  marc
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
