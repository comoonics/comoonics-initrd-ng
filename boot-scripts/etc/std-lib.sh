#
# $Id: std-lib.sh,v 1.9 2009-06-04 06:32:05 reiner Exp $
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
#****h* comoonics-bootimage/stdfs-lib.sh
#  NAME
#    std-lib.sh
#    $id$
#  DESCRIPTION
#    Library for std operations
#*******

#****f* boot-lib.sh/sourceLibs
#  NAME
#    sourceLibs
#  SYNOPSIS
#    function sourceLibs(predir) {
#  DESCRIPTION
#    Sources the libraries needed. Sets up clutype and distribution in repository.
#  IDEAS
#  SOURCE
#
function sourceLibs {
	local predir=$1
	[ -e ${predir}/etc/sysconfig/comoonics ] && . ${predir}/etc/sysconfig/comoonics

    . ${predir}/etc/repository-lib.sh
    . ${predir}/etc/errors.sh
    . ${predir}/etc/chroot-lib.sh
    . ${predir}/etc/boot-lib.sh
    . ${predir}/etc/hardware-lib.sh
    . ${predir}/etc/network-lib.sh
    . ${predir}/etc/clusterfs-lib.sh
    . ${predir}/etc/stdfs-lib.sh
    . ${predir}/etc/defaults.sh
    . ${predir}/etc/xen-lib.sh
    [ -e ${predir}/etc/iscsi-lib.sh ] && source ${predir}/etc/iscsi-lib.sh
    [ -e ${predir}/etc/drbd-lib.sh ] && source ${predir}/etc/drbd-lib.sh

    local clutype=$(getCluType)
    . ${predir}/etc/${clutype}-lib.sh

    # including all distribution dependent files
    local distribution=$(getDistribution)
    temp=( $(getDistributionList) )
    local shortdistribution=${temp[0]}
    unset temp

    for _distribution in $shortdistribution $distribution; do
      [ -e ${predir}/etc/${_distribution}/boot-lib.sh ] && source ${predir}/etc/${_distribution}/boot-lib.sh
      [ -e ${predir}/etc/${_distribution}/hardware-lib.sh ] && source ${predir}/etc/${_distribution}/hardware-lib.sh
      [ -e ${predir}/etc/${_distribution}/network-lib.sh ] && source ${predir}/etc/${_distribution}/network-lib.sh
      [ -e ${predir}/etc/${_distribution}/clusterfs-lib.sh ] && source ${predir}/etc/${_distribution}/clusterfs-lib.sh
      [ -e ${predir}/etc/${_distribution}/${clutype}-lib.sh ] && source ${predir}/etc/${_distribution}/${clutype}-lib.sh
      [ -e ${predir}/etc/${_distribution}/xen-lib.sh ] && source ${predir}/etc/${_distribution}/xen-lib.sh
      [ -e ${predir}/etc/${_distribution}/iscsi-lib.sh ] && source ${predir}/etc/${_distribution}/iscsi-lib.sh
      [ -e ${predir}/etc/${_distribution}/drbd-lib.sh ] && source ${predir}/etc/${_distribution}/drbd-lib.sh
    done
    unset _distribution
    
    # store the data to repository
    repository_store_value distribution $distribution
    repository_store_value shortdistribution $shortdistribution
    repository_store_value clutype $clutype 
}
#********** sourceLibs
#****f* boot-lib.sh/sourceRootfsLibs
#  NAME
#    sourceLibs
#  SYNOPSIS
#    function sourceRootfsLibs(predir) {
#  DESCRIPTION
#    Sources the libraries needed for the specific roots. Sets up rootfs in repository.
#  IDEAS
#  SOURCE
#
function sourceRootfsLibs {
	local predir=$1
    local rootfs=$(getParameter rootfs $(cc_getdefaults rootfs))
    local clutype=$(repository_get_value clutype)
    local shortdistribution=$(repository_get_value shortdistribution)
    local distribution=$(repository_get_value distribution)

    if [ "$clutype" != "$rootfs" ]; then
	  [ -e ${predir}/etc/${rootfs}-lib.sh ] && source ${predir}/etc/${rootfs}-lib.sh
	  [ -e ${predir}/etc/${shortdistribution}/${rootfs}-lib.sh ] && source ${predir}/etc/${shortdistribution}/${rootfs}-lib.sh
	  [ -e ${predir}/etc/${distribution}/${rootfs}-lib.sh ] && source ${predir}/etc/${distribution}/${rootfs}-lib.sh
	  # special case for nfs4
	  if [ "${rootfs:0:3}" = "nfs" ]; then
	     [ -e ${predir}/etc/nfs-lib.sh ] && source ${predir}/etc/nfs-lib.sh
	     [ -e ${predir}/etc/${shortdistribution}/nfs-lib.sh ] && source ${predir}/etc/${shortdistribution}/nfs-lib.sh
	     [ -e ${predir}/etc/${distribution}/nfs-lib.sh ] && source ${predir}/etc/${distribution}/nfs-lib.sh
	  fi
    fi
}
#********** sourceRootfsLibs

#****f* boot-lib.sh/initEnv
#  NAME
#    initEnv
#  SYNOPSIS
#    function initEnv() {
#  DESCRIPTION
#    Initializes basic things
#  IDEAS
#  SOURCE
#
function initEnv {
  # copied from redhat /etc/init.d/functions
  TEXTDOMAIN=initscripts

  # Make sure umask is sane
  umask 022

  # Get a sane screen width
  [ -z "${COLUMNS:-}" ] && COLUMNS=80

  [ -z "${CONSOLETYPE:-}" ] && [ -e "$CONSOLETYPE" ] && CONSOLETYPE="`/sbin/consoletype`"

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
    if [ -f /etc/sysconfig/init-comoonics ]; then
      . /etc/sysconfig/init-comoonics
    else
      # This all seem confusing? Look in /etc/sysconfig/init,
      # or in /usr/doc/initscripts-*/sysconfig.txt
      BOOTUP=color
      RES_COL=60
      MOVE_TO_COL="echo -en \\033[${RES_COL}G"
      SETCOLOR_SUCCESS="echo -en \\033[1;34m"
      SETCOLOR_FAILURE="echo -en \\033[1;31m"
      SETCOLOR_WARNING="echo -en \\033[1;35m"
      SETCOLOR_NORMAL="echo -en \\033[0;39m"
      LOGLEVEL=1
    fi
    if [ "$CONSOLETYPE" = "serial" ]; then
      BOOTUP=serial
      MOVE_TO_COL=
      SETCOLOR_SUCCESS=
      SETCOLOR_FAILURE=
      SETCOLOR_WARNING=
      SETCOLOR_NORMAL=
    fi
  fi

  if [ "${BOOTUP:-}" != "verbose" ]; then
    INITLOG_ARGS="-q"
  else
    INITLOG_ARGS=
  fi
}
#********** initEnv


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
  if [ -n "$1" ]; then
    return_c=$1
  fi
  if [ -n "$return_c" ] && [ $return_c -eq 0 ]; then
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
  if [ -n "$1" ]; then
    return_c=$1
  fi
  if [ -n "$return_c" ] && [ $return_c -eq 0 ]; then
    success
  else
    passed
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
#  echo -n "[  " >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
  echo -n "OK"
  echo -n "OK" >&3
#  echo -n "OK" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "  ]"
  echo "  ]" >&3
#  echo "  ]" >&5
  echo -ne "\r"
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
#  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
  echo -n "FAILED"
  echo -n "FAILED" >&3
#  echo -n "FAILED" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
  echo -ne "\r"
  echo "]" >&3
#  echo "]" >&5
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
#  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
  echo -n "WARNING"
  echo -n "WARNING" >&3
#  echo -n "WARNING" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
  echo -ne "\r"
  echo "]" >&3
#  echo "]" >&5
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
#  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
  echo -n "PASSED"
  echo -n "PASSED" >&3
#  echo -n "PASSED" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
  echo -ne "\r"
  echo "]" >&3
#  echo "]" >&5
#  echo -ne "\r" >&3
  return 1
}
#********** passed

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
    echo ${*:0:$#-1} "${*:$#}" >&2
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
  local debug=$(repository_get_value debug)
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
  local debug=$(repository_get_value debug)
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
  local debug=$(repository_get_value debug)
  local do_exec=1
  if [ -n "$(repository_get_value dstep)" ]; then
  	echo -n "$* (Y|n|c)? " >&2
  	read dstep_ans
  	[ "$dstep_ans" == "n" ] && do_exec=0
  	[ "$dstep_ans" == "c" ] && dstepmode=""
  fi
  if [ $do_exec -eq 1 ]; then
  	output=$($*)
  else
  	output="skipped"
  fi
  return_c=$?
  if [ ! -z "$debug" ]; then
    echo "cmd: $*" >&2
    echo "OUTPUT: $output" >&2
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
  local debug=$(repository_get_value debug)
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
  local debug=$(repository_get_value debug)
	reps=$1
	stime=$2
 	shift 2
	ret=1

 	for i in $(seq $reps); do
 		if [ ! -z "$debug" ]; then
 			echo "start_service_chroot run: $i, sleeptime: $stime"
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
   local __message="$1"
   local __name="$2"
   local __stepmode=$(repository_get_value step)
   local steps
   if [ -n "$__stepmode" ] && [ "$__stepmode" == "__set__" ]; then
   	 echo -n "$__message: "
     echo -n "Press <RETURN> to continue (timeout in $step_timeout secs) [quit|break|continue|list]"
     read -t$step_timeout __the_step
     case "$(echo $__the_step | tr A-Z a-z)" in
       "q" | "qu" | "qui" |"quit")
         exit_linuxrc 2
         ;;
       "c" | "co" | "con" | "cont" | "conti" | "contin" | "continu" | "continue")
         __stepmode=""
         ;;
       "b" | "br" | "bre"  | "brea" | "break")
         echo_local "Break detected forking a shell"
         breakp
         repository_load
         return 0
         ;;
       "l" | "li" | "lis" | "list")
         echo_local "List of breakpoints:"
         listBreakpoints
         echo
         step "List done!" "$__name"
         return 0
         ;;
       *)
         if [ -n "$__the_step" ]; then
         	for _pb in $(listBreakpoints); do
         		if [ $__the_step = $_pb ]; then
         			echo_local "Setting breakpoint to \"$__the_step\".."
         			__stepmode=$__the_step
         			break
         		fi
         	done
         	echo
         fi
         ;;
     esac
     if [ -z "$__the_step" ]; then
       echo
     fi
     if [ -n "$__the_step" ] && [ "$__the_step" != "$(repository_get_value step)" ]; then
       repository_store_value step "$__stepmode"
     fi
   elif [ -n "$__stepmode" ] && [ -n "$__name" ] && [ "$__name" == "$__stepmode" ]; then
     # reseting if came from a breakpoint.
     __stepmode="__set__"
     repository_store_value step "$__stepmode"
     echo_local "Breakpoint \"$__name\" detected forking a shell"
     breakp
   else
     return 0
   fi
}
#************ step

#****f* boot-lib.sh/listBreakpoints
#  NAME
#    listBreakpoints
#  SYNOPSIS
#    function listBreakpoints() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function listBreakpoints {
	for file in $(find ./ -name "*.sh"); do 
		awk '
/step[[:space:]]+"/ && $0 !~ /__name/ { 
	step=$0; 
	sub(/step[[:space:]]+/, "", step); 
	gsub(/"/, "", step); split(step, steps); 
	print steps[NF-1];
}' < $file; done
}
#************ listBreakpoints

#****f* boot-lib.sh/breakp
#  NAME
#    break
#  SYNOPSIS
#    function breakp( info ) {
#  MODIFICATION HISTORY
#  IDEAS
#    Modify or debug a running skript
#  DESCRIPTION
#  SOURCE
#
function breakp() {
    local shell=$(repository_get_value shell)
    local issuetmp=$(repository_get_value shellissuetmp)
    [ -z "$shell" ] && shell="/bin/sh" 
    echo -e "$*" >  $issuetmp
	echo "Type exit to continue work.." >> $issuetmp
	if [ -n "$simulation" ] && [ $simulation ]; then
	  $shell
	else
	  TERM=xterm $shell &>/dev/console
    fi
    echo_local "Back to work.."
    rm -f $rcfile
}
#*********** breakp

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
    local __stepmode=$(repository_get_value step)
    while getopts "RsdShb:B" Option
      do
      case $Option in
          S ) # executed from simulator mode
              simulation=1
              ;; 
	  R ) # running non recursive for nfs-mounts
	      non_recursive=1
	      ;;
          s) # stepmode
              __stepmode=1
	      ;;
	  d) # debug
	      debug=1
	      ;;
	  h) # help
	      usage
	      exit 0
	      ;;
	  b) # break
	      __stepmode=$OPTARG
	      echo "Breakpoint set to $__stepmode"
	      ;;
	  B) # list all breakpoints
	      listBreakpoints
	      exit 0
	      ;;
	  *)
	      echo "Wrong option."
	      usage
	      exit 1
	      ;;
      esac
    done
    repository_store_value step "$__stepmode"
    return $OPTIND;
}
#************ check_cmd_params

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
    echo -e "\t-s: set stepmode (s) or unset stepmode (S)"
    echo -e "\t-b: break at the given parameter"
    echo -e "\t-d: set debugmode (d) or unset stepmode (D)"
    echo -e "\t-h:   this usage."
    echo -e "\t-S: set simulator mode to on."
    echo -e "\t-B: output all breakpoints"
}
#************ usage

#****f* std-lib.sh/cpio_and_zip_initrd
#  NAME
#    cpio_and_zip_initrd
#  SYNOPSIS
#    function cpio_and_zip_initrd() {
#  DESCRIPTION
#    Creates an imagefile with cpio and compresses it with zip
#
function cpio_and_zip_initrd() {
  local mountpoint=$1
  local filename=$2
  local force=$3
  local opts=""
  [ -z "$compression_cmd" ] && compression_cmd="gzip"
  [ -z "$compression_opts" ] && compression_opts="-c -9"
  [ -n "$force" ] && [ $force -gt 0 ] && opts="-f"
  ((cd $mountpoint; find . | cpio --quiet -c -o) >| ${filename}.tmp && $compression_cmd $compression_opts $opts ${filename}.tmp > $filename && rm ${filename}.tmp)|| (fuser -mv "$mountpoint" && exit 1)
}
#************ cpio_and_zip_initrd

#****f* std-lib.sh/unzip_and_uncpio_initrd
#  NAME
#    unzip_and_uncpio_initrd
#  SYNOPSIS
#    function unzip_and_uncpio_initrd() {
#  DESCRIPTION
#    Unpacks a zipped cpio image
#
function unzip_and_uncpio_initrd() {
  local mountpoint=$1
  local filename=$2
  local force=$3
  local opts=""
  [ -z "$compression_cmd" ] && compression_cmd="gzip"
  [ -z "$compression_opts_un" ] && compression_opts_un="-c -d"
  [ -n "$force" ] && [ $force -gt 0 ] && opts="-f"
  pushd $mountpoint >/dev/null 2>&1
  $compression_cmd $compression_opts_un $filename | cpio -i -d -m
  popd >/dev/null 2>&1
}
#************ unzip_and_uncpio_initrd

#****f* std-lib.sh/get_files_newer
#  NAME
#    get_files_newer
#  SYNOPSIS
#    function get_files_newer(PATHS) {
#  DESCRIPTION
#    reads a list of files from stdin and finds then relative to paths.
#
function get_files_newer() {
	local file=
	local line=
	local mtime=
	local file2=
	local paths=$@
	while read line; do
		file=$(echo $line | cut -s -d';' -f1)
	    mtime=$(echo $line | cut -s -d';' -f2)
		file2=$(find_file $file $paths)
		if is_newer $file "$mtime" $file2 ""; then
			echo $file2
		fi
	done
}
#******* get_files_newer

#****f* std-lib.sh/create_filelist
#  NAME
#    create_filelist
#  SYNOPSIS
#    function create_filelist(path) {
#  DESCRIPTION
#    Creates a filelist for a given path.
#
function create_filelist() {
	path=$1
	pushd $path >/dev/null 2>&1
    find ./ -not -type d -printf "%p;%T@\n"
    popd >/dev/null 2>&1 
}
#******* create_filelist

#****f* std-lib.sh/get_mappaths_from_depfiles
#  NAME
#    get_mappaths_from_depfiles
#  SYNOPSIS
#    function get_mappaths_from_depfiles(PATHS) {
#  DESCRIPTION
#    finds a files in paths and outputs the full path.
#
function get_mappaths_from_depfiles() {
   local depfile=$1
   resolve_file $depfile | grep "@map" | cut -s -d'&' -f2
}
#******* get_mappaths_from_depfiles

function create_python_dict_from_mappaths {
	local mappaths=$@
	local mappath=
	for mappath in $mappaths; do
		echo '"'$mappaths'":"/",'
	done
}

#****f* std-lib.sh/find_file
#  NAME
#    find_file
#  SYNOPSIS
#    function find_file(PATHS) {
#  DESCRIPTION
#    finds a files in paths and outputs the full path.
#
function find_file() {
	local file=$1
	local paths=${@:2}
	local path
	
	if [ -z "$paths" ]; then
		paths="/ ."
	fi
	
	for path in $paths; do
		if [ -e ${path}/$file ]; then
			echo ${path}/$file | sed -e 's/\/\//\//g'
			return 0
		fi
	done
	return 1
}
#********* find_file

#****f* std-lib.sh/is_newer
#  NAME
#    is_newer
#  SYNOPSIS
#    function is_newer(file1, file2) {
#  DESCRIPTION
#    returns 0 if file2 is newer (modification time) then file1.
#
function is_newer() {
	local file1=$1
	local mtime1=$2
	local file2=$3
	local mtime2=$4

	if [ -z "$mtime1" ]; then
		mtime1=$(stat -c "%Y" $file1 2>/dev/null)
	fi
	if [ -z "$mtime2" ]; then
		mtime2=$(stat -c "%Y" $file2 2>/dev/null)
	fi

	if [ -z "$mtime1" ] || [ -z "$mtime2" ]; then
		return 2
	fi
	
	if [ $mtime1 -lt $mtime2 ]; then
		return 0
	else
		return 1
    fi	
}
#********* is_newer

#################
# $Log: std-lib.sh,v $
# Revision 1.9  2009-06-04 06:32:05  reiner
# Modified step function so that valid step commands are recognized in uppercase and when abbreviated.
#
# Revision 1.8  2009/04/14 14:57:35  marc
# added functions to unpack the initrd and find newer files
#
# Revision 1.7  2009/02/27 08:38:59  marc
# fixed bash strangeness with rhel4
#
# Revision 1.6  2009/01/28 12:56:01  marc
# Many changes:
# - moved some functions to std-lib.sh
# - no "global" variables but repository
# - bugfixes
# - support for step with breakpoints
# - errorhandling
# - little clean up
# - better seperation from cc and rootfs functions
#
