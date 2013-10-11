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

step_timeout=10
bootlog="/var/log/comoonics-boot.log"
syslog_logfile="/var/log/comoonics-boot.syslog"
error_code_file="/var/error_code"
init_cmd_file="/var/init_cmd"
init_chroot_file="/var/init_chroot_file"
# the disk where the bootlog should be written to (default /dev/fd0).
diskdev="/dev/fd0"
which logger &>/dev/null
[ $? -eq 0 ] && logger="logger -t com-bootlog"
modules_conf="/etc/modprobe.conf"

# Default init cmd is bash
init_cmd="/bin/bash"

# TODO: consolidate mount_point , new_root and newroot to newroot
#mount_point="/mnt/newroot"

# The comoonics buildfile
build_file="/etc/comoonics-build.txt"

atixlogofile="/etc/atix-logo.txt"

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
    local error_code=$1
    local init_cmd=$2
    local newroot=$3
    local chrootneeded=$4
    echo_local_debug "exit_linuxrc($error_code, $initcmd, $newroot, $chrootneeded)"
    if [ -z "$error_code" ]; then
	error_code=0
    fi
    echo $error_code > $error_code_file
    repository_store_value chrootneeded $chrootneeded
	exit $error_code
}
#************ exit_linuxrc

#****f* boot-lib.sh/getBootParm
#  NAME
#    getBootParm
#  SYNOPSIS
#    function getBootParm(param, [default])
#  DESCRIPTION
#    Gets the given parameter from the bootloader command line. If not
#    found default or the empty string is echoed.
#    If the parameter has been found or default is given 0 is returned 1 otherwise.
#  SOURCE
#
function getBootParm() {
   local parm="$1"
   local default="$2"
   if [ -z "$3" ] && [ -z "$cmdline" ]; then
     local _cmdline=`cat /proc/cmdline`
   elif [ -n "$cmdline" ]; then
     local _cmdline="$cmdline" 
   else
     local _cmdline="$3"
   fi
   local found=1
   local out=""

   for param in $_cmdline; do
     local name=$(echo $param | cut -f1 -d=)
     local value=$(echo $param | cut -f2- -d=)
     
     if [ -n "$name" ] && [ "$name" = "$parm" ]; then
     	if [ "$name" = "$value" ]; then
     	  out=""
        else
          out=$value
        fi
    	found=0
     fi 
   done
   if [ -z "$out" ] && [ -n "$default" ]; then 
   	 out="$default"
   	 found=0
   fi
   #out=`expr "$cmdline" : ".*$parm=\([^ ]*\)" 2>/dev/null`
   #if [ -z "$out" ]; then
   #	  if [ $(expr "$cmdline" : ".*$parm" 2>/dev/null) -gt 0 ]; then out=1; fi
   #   if [ -z "$out" ]; then out="$default"; fi
   #fi
   echo -n "$out"
   #if [ -z "$out" ]; then
   #    return 1
   #else
   #    return 0
   #fi
   return $found
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

#****f* boot-lib.sh/getDistribution
#  NAME
#    getDistribution
#  SYNOPSIS
#    funtion getDistribution
#  DESCRIPTION
#    Returns the shortdescription of this distribution. Valid return strings are
#    e.g. rhel4, rhel5, sles10, fedora9, ..
#  SOURCE
function getDistribution {
    local temp
	temp=( $(getDistributionList) )
	echo ${temp[0]}""${temp[1]}
}
#**** getDistribution

#****f* boot-lib.sh/getDistributionList
#  NAME
#    getDistributionList
#  SYNOPSIS
#    funtion getDistributionList
#  DESCRIPTION
#    returns the shortname of the Linux Distribution and version as 
# defined in the /etc/..-release files. E.g. rhel 4 7 is returned for the redhat enterprise 
# linux verion 4 U7. 
#  SOURCE
function getDistributionList {
	if [ -e /etc/redhat-release ]; then
		awk '
		   BEGIN { shortname="unknown"; version=""; }
	       tolower($0) ~ /red hat enterprise linux/ || tolower($0) ~ /centos/ || tolower($0) ~ /scientific/ || tolower($0) ~ /enterprise linux enterprise linux/ { 
	       	  shortname="rhel";
	       	  match($0, /release ([[:digit:]]+)/, _version);
	       	  version=_version[1] 
	       }
	       tolower($0) ~ /fedora/ {
	       	  shortname="fedora"
	       	  match($0, /release ([[:digit:]]+)/, _version);
	       	  version=_version[1] 
	       }
	       {
	       	 next;
	       } 
	       END {
	       	 print shortname,version;
	       }' < /etc/redhat-release 
#		
#    	if cat /etc/redhat-release | grep -i "release 4" &> /dev/null; then
#     		echo "rhel4"
#   	 	elif cat /etc/redhat-release | grep -i "release 5" &> /dev/null; then
#   	 		echo "rhel5"
#    	else
#    	    echo "rhel5"
#    	fi
    elif [ -e /etc/SuSE-release ]; then
        awk -vdistribution=sles '
        /VERSION[[:space:]]*=[[:space:]]*[[:digit:]]+/ { 
        	print distribution,$3;
        }' /etc/SuSE-release
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
	local name=$1
	local default=${2:-__set__}
	local out=""
	
	# first check for a boot parameter
        if out=$(getBootParm $name); then
        # set __set__ for parameters given as 
		[ -z "$out" ] && out="__set__"
	# check if parameter is already in repository
    elif repository_has_key $name; then
        out=$(repository_get_value $name)
    # if we cannot find this one, try with a "com-"
	elif out=$(getBootParm com-$name); then
        # set __set__ for parameters given as 
		[ -z "$out" ] && out="__set__"
	# then we try to find a method to query the cluster configuration
	elif out=$(getClusterParameter $name); then
        # set __set__ for parameters given as 
		[ -z "$out" ] && out="$default"
    elif [ -n "$default" ] && [ -n "$2" ]; then
        out=$default
    fi
    if [ -n "$out" ]; then
        repository_store_value $name "$out"
        echo "$out"
        return 0
    else
        return 1
    fi
}
#************ getParameter

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
	local _logofile=$2
	if [ -n "$_logofile" ] && [ -e "$_logofile" ]; then
		cat $_logofile
	fi

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

#****f* boot-lib.sh/initHaltProcess
#  NAME
#    initBootProcess
#  SYNOPSIS
#    function initBootProcess() {
#  MODIFICATION HISTORY
#  IDEAS
#     function to integrate setup of halt environment before we start with it.
#  SOURCE
#
function initHaltProcess() {
   local distribution=$(repository_get_value distribution)
   
   typeset -f ${distribution}_PrepareHalt >/dev/null 2>&1 && ${distribution}_PrepareHalt
   initEnv
}
#********* initHaltProcess

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

  echo "***********************************"
  # Print a text banner.
  release=$(cat ${predir}/etc/comoonics-release)
  echo -en $"\t\tWelcome to "
  [ "$BOOTUP" = "color" ] && echo -en "\\033[0;34m"
  echo $release
  [ "$BOOTUP" = "color" ] && echo -en "\\033[0;39m"
  echo "Starting Open Shared Root Boot Process"
  echo "Date: $date"
  echo "***********************************"

  echo_local_debug "*****************************"
  echo_local -n "Mounting Proc-FS"
  is_mounted /proc
  if [ $? -ne 0 ]; then 
  	[ -d /proc ] || mkdir /proc
    exec_local /bin/mount -t proc proc /proc
    return_code
  else
    passed  
  fi

  echo_local -n "Mounting Sys-FS"
  is_mounted /sys
  if [ $? -ne 0 ]; then
  	[ -d /sys ] || mkdir /sys 
    exec_local /bin/mount -t sysfs sysfs /sys
    return_code
  else
    passed
  fi

  exec_local dev_start

  echo_local_debug "/proc/cmdline"
  exec_local_debug cat /proc/cmdline

  for dir in /tmp /mnt/newroot /var/lock/subsys; do
  	[ -d $dir ] || mkdir -p $dir
  done
  
  rm -f /etc/mtab
  ln -s /proc/mounts /etc/mtab
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
	local chroot_dir=
	local service_name=
	
	chroot_dir=$1
	shift
	service_name=$1
	shift
	echo_local -n "Starting service [$chroot_dir] $service_name"
	exec_local chroot $chroot_dir $service_name $*
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
  local nochroot=
  local onlycopy=
  local nofailback=
  local dir=/etc
  local chroot_dir=""
  local service=
  local aservice=
  local service_name=
  local service_dirs=
  local service_mv_files=
  local service_cp_files=
  local file=
  
  [ -d "$1" ] && chroot_dir=$1 && shift
  service=$1
  shift
  aservice=( $service )
  service_name=$(basename ${aservice[0]})
  [ -n "$chroot_dir" ] && [ "$chroot_dir" = "no_chroot" ] && nochroot=1
  [ -z "$chroot_dir" ] && nochroot=1
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
    exec_local $service $*
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
      exec_local chroot $chroot_dir $service $*
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
  local chrootneeded=$2
  local cominit="/usr/comoonics/sbin/init"
  if [ -z "$new_root" ]; then
     newroot="/mnt/newroot"
  fi

  echo_local "**********************************************************************"
  echo_local  " comoonics generic switchroot"
  echo_local " newroot=$newroot chrootneeded=$chrootneeded "

  # needed for SuSE 11
  export ROOTFS_BLKDEV=$(repository_get_value root)
  export ROOTFS_REALDEV=$(repository_get_value root)
  
  #get init_cmd from /proc
  if [ -n "$chrootneeded" ] && [ "$chrootneeded" -eq 0 ] && [ -e "$newroot/$cominit" ]; then
  	init_cmd="$cominit $(cat /proc/cmdline)"
  	echo_local_debug "found init in $init_cmd"
  else
  	init_cmd="/sbin/init $(cat /proc/cmdline)"
  fi
  
  switch_root=$(which switch_root 2>/dev/null)
  if [ -n "$switch_root" ] && [ -x $switch_root ]; then
  	$switch_root $newroot $init_cmd 
  else
    # clean up
    if [ -f /etc/boot-environment ]; then
      echo_local_debug "Sourcing environment"
  	  source /etc/boot-environment
    fi

    for fs in /proc /sys; do
      if ! is_mounted ${newroot}$fs; then
        echo_local -n "Mounting filesystem $fs in ${newroot}.."
        exec_local chroot ${newroot} mount $fs
        return_code
      fi
    done

    for fs in /sys /proc; do
      if is_mounted $fs; then
        for depfilesystem in $(get_dep_filesystems $fs); do
          if is_mounted $depfilesystem; then 
            echo_local -n "Umounting $depfilesystem"
            exec_local umount_filesystem $depfilesystem
            return_code
            [ $return_c -eq 0 ] || rc=$return_c
          fi
        done
        echo_local -n "Umounting $fs"
        exec_local umount_filesystem $fs
        return_code
        [ $return_c -eq 0 ] || rc=$return_c
      fi
    done
    echo_local "Cleaning up..."
    # this returns a comand to delete all unused files.
    # TODO: directories are not removed. Add functionality to remove empty directories.
    # CAUTION: Do NOT remove /mnt/newroot ;-)
    skipfiles=$(for file in $skipfiles; do which $file; done)
    skipfiles=$(for file in $skipfiles; do get_dependent_files $file; which $file; done | sort -u)
    skipfiles="$skipfiles /dev/console"
    skipfiles=$(echo $skipfiles | sort -u | sed 's/ /" -o -regex "/g')
    cmd=$(echo find / -xdev ! \\\( -regex \"$skipfiles\" \\\) -exec 'rm {}' '\;')

    eval $cmd > /dev/null 2>&1
  
    # It happens that sometimes a lockfile is being left over by udev or the initprocess. 
    # So we'll remove any stale lockfile either in /dev or /var/lock/subsys
    find ${newroot}/var/lock/subsys -type f -delete 2>/dev/null
    find ${newroot}/dev -name ".*.lock" -or -name "*.lock" -delete 2>/dev/null

    cd ${newroot}
    /bin/mount --move . /
    echo_local_debug "Calling init as $init_cmd"
    exec chroot . $init_cmd </dev/console >/dev/console 2>&1
  fi
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
		echo_local -N -n "builddate_file"
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
	mount -t sysfs sysfs /sys
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
	exec_local telinit u || exec_local telinit u
	sleep 4
}
#************ restart_init

#****f* boot-lib.sh/stop_service
#  NAME
#    stop_service
#  SYNOPSIS
#    function stop_service(service_name, root=/, force=1) {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function stop_service {
  local service_name=$1
  local other_root=$2
  local force=${3:-1}
  local pids=$(pidof $service_name 2>/dev/null)
  local pid=
  if [ -f ${other_root}/var/run/${service_name}.pid ]; then
    pids=$(cat ${other_root}/var/run/${service_name}.pid)
  fi
  for pid in $pids; do
  	local root=$(/bin/ls --directory --inode /proc/$pid/root/ 2>/dev/null | cut -f1 -d" ")
  	local other_root=$(/bin/ls --directory --inode $other_root 2>/dev/null | cut -f1 -d" ")
  	if [ -z "$root" ] || [ -z "$other_root" ] || [ $root = "1" ] || [ "$root" -eq "$other_root" ]; then
   	  kill $pid 2>/dev/null
   	  kill -0 $pid 2>/dev/null
   	  if [ -n "$force" ]; then
   		sleep 2 && kill -0 $pid 2>/dev/null && kill -9 $pid 2>/dev/null
   	  fi
   	fi
  done
  for pid in $pids; do
  	local root=$(/bin/ls --directory --inode /proc/$pid/root/ 2>/dev/null | cut -f1 -d" ")
  	local other_root=$(/bin/ls --directory --inode $other_root 2>/dev/null | cut -f1 -d" ")
  	if [ -z "$root" ] || [ -z "$other_root" ] || [ $root = "1" ] || [ "$root" -eq "$other_root" ]; then
   	  kill -0 $pid 2>/dev/null
  	  if [ $? -ne 0 ]; then
  		return $?
  	  fi
  	fi
  done
  return 0
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
	local procs="udevd dmeventd"
	echo_local_debug -N -n "Sending unnecessary processes the TERM signal"
	for p in $procs; do
		killall -0 $p &> /dev/null && killall $p &> /dev/null
	done
	sleep 3
	echo_local_debug -N -n "Sending unnecessary processes the KILL signal"
	for p in $procs; do
		killall -0 $p &> /dev/null && killall -9 $p &> /dev/null
	done
	true
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

#****f* boot-lib.sh/create_xtab
#  NAME
#    create_xtab build a chroot environment
#  SYNOPSIS
#    function create_xtab($xtabfile, $dirs) {
#  MODIFICATION HISTORY
#  USAGE
#  create_xtab
#  IDEAS
#
#  SOURCE
#
function create_xtab () {
	local xtabfile="$1"
	local _dir
	shift
	# truncate
	echo -n > $xtabfile
	for _dir in $*; do
	  echo "$_dir" >> $xtabfile
	done
}
#************** create_xtab

#****f* boot-lib.sh/create_xrootfs
#  NAME
#    create_xrootfs build a chroot environment
#  SYNOPSIS
#    function create_xrootfs($xrootfsfile, $rootfss) {
#  MODIFICATION HISTORY
#  USAGE
#  create_xrootfs
#  IDEAS
#
#  SOURCE
#
function create_xrootfs () {
	local xrootfsfile="$1"
	local _rootfs
	shift
	# truncate
	echo -n > $xrootfsfile
	for _rootfs in $*; do
	  echo "$_rootfs" >> $xrootfsfile
	done
}
#************** create_xrootfs

#****f* boot-lib.sh/create_xkillall_procs
#  NAME
#    create_xkillall_procs build a chroot environment
#  SYNOPSIS
#    function create_xkillall_procs($xkillall_procsfile, $rootfss) {
#  MODIFICATION HISTORY
#  USAGE
#  create_xkillall_procs
#  IDEAS
#
#  SOURCE
#
function create_xkillall_procs () {
	local xkillall_procsfile="$1"
	local _clutype="$2"
	local _rootfs="$3"
	local _proc=
	shift
	# truncate
	echo -n > $xkillall_procsfile
	for _proc in $(cc_get_userspace_procs $_clutype); do
	  echo "$_proc" >> $xkillall_procsfile
	done
	if [ "$_clutype" != "$_rootfs" ]; then
	  for _proc in $(clusterfs_get_userspace_procs $_rootfs); do
	    echo "$_proc" >> $xkillall_procsfile
	  done
	fi
}
#************** create_xkillall_procs

#****f* boot-lib.sh/detectHalt
#  NAME
#    detectHalt build a chroot environment
#  SYNOPSIS
#    function detectHalt($xkillall_procsfile, $rootfss) {
#  MODIFICATION HISTORY
#  USAGE
#  detectHalt
#  IDEAS
#
#  SOURCE
#
detectHalt() {
    local runlevel2=$1
	local distribution=$(repository_get_value distribution)
	local shortdistribution=$(repository_get_value shortdistribution)
    local cmd="halt"
    cmd=$(${distribution}_detectHalt $* 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$cmd" ]; then
      cmd=$(${shortdistribution}_detectHalt $* 2>/dev/null)
      if [ $? -ne 0 ] || [ -z "$cmd" ]; then
        if [ $runlevel2 -eq 0 ]; then
  	      cmd="halt -d -f"
  	      echo_local -n "..halt.." >&2
        elif [ $runlevel2 -eq 6 ]; then
          cmd="reboot -d -f"
  	      echo_local -n "..reboot.." >&2
        else
          cmd="halt"
  	      echo_local -n "..reboot.." >&2
        fi
      fi
    fi
    echo "$cmd"
    [ -n "$cmd" ]
}
#************** detectHalt

#****f* bootsr/check_mtab
#  NAME
#    check_mtab
#  SYNOPSIS
#    function check_mtab rootfstype cdslpath cdsllink
#  IDEAS
#    Checks if the mtab is a file (not a link) and if so checks if all filesystems mounted within the initrd are also in the mtab
#    Returns 0 on success 1 on failure
function check_mtab {
	local fs_type=$1
	local mountpoint=$2
	local cdslpath=$3
	local cdsllink=$4
	local root=$5
    [ -z "$CDSLINVADM" ] && CDSLINVADM=com-cdslinvadm
	
	[ -z "$root" ] && root="/"
	[ -z "$mountpoint" ] && mountpoint="/"
	[ -z "$cdslpath" ] && cdslpath=$($CDSLINVADM --mountpoint=$mountpoint --root=$root --get=tree)
	[ -z "$cdsllink" ] && cdsllink=$($CDSLINVADM --mountpoint=$mountpoint --root=$root --get=link)
	
	cdsllink=${mountpoint}/$cdsllink
	cdsllink=${cdsllink//\/\//\/}
	if [ -f /etc/mtab ] && [ -n "$cdsllink" ] && [ -e "$cdsllink" ]; then
		cat /proc/mounts | cut -d" " -f2 | grep $cdsllink >/dev/null &>/dev/null
		if [ $? -eq 0 ]; then
			cat /etc/mtab | cut -d" " -f2 | grep $cdsllink >/dev/null &>/dev/null
			if [ $? -ne 0 ]; then
				return 0
			fi
		fi
	fi
	return 1
} 
#************** check_mtab

#****f* bootsr/initrd_exit_postsettings
#  NAME
#    initrd_exit_postsettings
#  SYNOPSIS
#    function initrd_exit_postsettings(distribution)
#  IDEAS
#    Calls the dependent postsettings functions
function initrd_exit_postsettings {
  local distribution=${1:-$(repository_get_value distribution)}
  local rc=0

  if typeset -f ${distribution}_initrd_exit_postsettings &>/dev/null; then
    ${distribution}_initrd_exit_postsettings $*
    rc=$?
  fi
  
  return $rc
} 
#************** initrd_exit_postsettings
