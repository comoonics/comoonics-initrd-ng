#
# $Id: syslog-lib.sh,v 1.1 2009-09-28 13:08:10 marc Exp $
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

#****f* clusterfs-lib.sh/detect_syslog
#  NAME
#    detect_syslog
#  SYNOPSIS
#    function detect_syslog()
#  DESCRIPTION
#    Detects the syslog implementation to be used. Supports rsyslog, syslog, syslog-ng
#  SOURCE
detect_syslog() {
    local syslogtype=""
    if [ -e /sbin/rsyslogd ]; then
	   syslogtype="rsyslogd"
    elif [ -e /sbin/syslogd ]; then
       syslogtype="syslogd"
    elif [ -e /sbin/syslog-ng ]; then
       syslogtype="syslog-ng"
    else
       warn "Could not find any syslog binary although the syslogmodule is selected to be installed. Please check."
    fi
    echo "$syslogtype"
    [ -n "$syslogtype" ]
}	
#******** detect_syslog

#****f* clusterfs-lib.sh/default_syslogconf
#  NAME
#    default_syslogconf
#  SYNOPSIS
#    function default_syslogconf()
#  DESCRIPTION
#    Detects the syslog implementation to be used. Supports rsyslog, syslog, syslog-ng
#  SOURCE
default_syslogconf() {
    local syslogtype=$1
    local return_code=0
    case "$syslogtype" in
       "rsyslogd") echo "/etc/rsyslogd.conf";;
       "syslog-ng") echo "/etc/syslog-ng/syslog-ng.conf";;
       "syslogd") echo "/etc/syslog.conf";;
       "*") 
          warn "No valid syslogtype \"$syslogtype\" detected. No configuration returned."
          return_code=1
    esac
    return $return_code    
}	
#******** default_syslogconf

#****f* clusterfs-lib.sh/syslogd_config
#  NAME
#    syslogd_config template filter:dest+
#  SYNOPSIS
#    function syslogd_config template filter:destination+
#  DESCRIPTION
#    Sets up the classical syslog server. I.e. creates the /etc/syslog.conf
#  SOURCE
syslogd_config() {
  local debug=$(repository_get_value debug)
  local syslog_conf_template=$1
  shift
  local dests=$@
  local dest
  local filter
  local dest
  
  [ -f "$syslog_conf_template" ] && cat $syslog_conf_template
  
  # Checking for normal syslog all others should be checked before so that this is the last resort syslog
  if [ -n "$debug" ]; then
    filters="$filters kern,daemon.*:/dev/console"
  fi
  
  for dest in $dests; do
  	filter=$(echo $dest | cut -d: -f1)
  	# default is all
  	[ -z "$filter" ] && filter="*.*"
  	dest=$(echo $dest | cut -d: -f2)
  	if [ -n "$filter" ] && [ -n "$dest" ]; then
      if [ "${dest:0:1}" = "/" ]; then
      	echo "$filter $dest"
      else
        echo "$filter @$dest"
  	  fi
    fi
  done
}
#************ syslogd_config

#****f* syslog-lib.sh/syslogd_start
#  NAME
#    syslogd_start
#  SYNOPSIS
#    function syslogd_start(chroot_path)
#  DESCRIPTION
#    Starts the syslogd as required
#  SOURCE
function syslogd_start {
	local chrootpath=$1
	local start_service_f="start_service_chroot $chrootpath"
	local syslog_sysconfig=$(repository_get_value "syslogsysconfig" "/etc/sysconfig/syslog")
	
    if [ -z "$chrootpath" ]; then
    	start_service_f=""
    fi

    if [ -f "$syslog_sysconfig" ] ; then
        . $syslog_sysconfig
    else
       SYSLOGD_OPTIONS="-m 0"
       KLOGD_OPTIONS="-2"
    fi

    if [ -z "$SYSLOG_UMASK" ] ; then
       SYSLOG_UMASK=077;
    fi
    umask $SYSLOG_UMASK
   
    which syslogd >/dev/null 2>/dev/null
    if [ $? -eq 0 ]; then
    	$start_service_f syslogd $SYSLOGD_OPTIONS
    fi
    which klogd > /dev/null 2>/dev/null
    if [ $? -eq 0 ]; then
    	$start_service_f klogd $KLOGD_OPTIONS
    fi
}
#******** syslogd_start

#****f* clusterfs-lib.sh/rsyslogd_config
#  NAME
#    rsyslogd_config
#  SYNOPSIS
#    function rsyslogd_config template filter:dest+
#  DESCRIPTION
#    Sets up the rsyslog server. I.e. creates the /etc/rsyslog.conf
#  SOURCE
rsyslogd_config() {
  # The rsyslog.conf is build exacltly the same except from the template
  syslogd_config $*
}
#*********** rsyslog_config

#****f* syslog-lib.sh/rsyslog_start
#  NAME
#    rsyslog_start
#  SYNOPSIS
#    function rsyslog_start(chroot_path)
#  DESCRIPTION
#    Starts the rsyslogd as required
#  SOURCE
function rsyslogd_start {
	local chrootpath=$1
	local start_service_f="start_service_chroot $chrootpath"
	local syslog_sysconfig=$(repository_get_value "syslogsysconfig" "/etc/sysconfig/rsyslog")
	
    if [ -z "$chrootpath" ]; then
    	start_service_f=""
    fi

    if [ -f "$syslog_sysconfig" ] ; then
        . $syslog_sysconfig
    else
       RSYSLOGD_OPTIONS="-c3"
    fi

    if [ -z "$SYSLOG_UMASK" ] ; then
       SYSLOG_UMASK=077;
    fi
    umask $SYSLOG_UMASK
   
	$start_service_f /sbin/rsyslogd $RSYSLOGD_OPTIONS
}
#*************** rsyslog_start

#****f* clusterfs-lib.sh/syslogng_config
#  NAME
#    syslogng_config template filter:dest+
#  SYNOPSIS
#    function syslogng_config template filter:destination+
#  DESCRIPTION
#    Sets up the classical syslog server. I.e. creates the /etc/syslog.conf
#  SOURCE
syslog_ng_config() {
  local debug=$(repository_get_value debug)
  local syslog_conf_template=$1
  shift
  local dests=$@
  local dest
  local filter
  local dest
  local i
  local facilities
  local facility
  local levels
  local level
  
  [ -f "$syslog_conf_template" ] && cat $syslog_conf_template
  
  # Checking for normal syslog all others should be checked before so that this is the last resort syslog
  if [ -n "$debug" ]; then
    filters="$filters kern,daemon.*:/dev/console"
  fi
  
  i=0
  for dest in $dests; do
  	filter=$(echo "$dest" | cut -d: -f1)
  	# default is all
  	[ -z "$filter" ] && filter='*.*'
  	dest=$(echo $dest | cut -d: -f2)
  	if [ -n "$filter" ] && [ -n "$dest" ]; then
  	  set -f
      facilities=( $(echo "$filter" | cut -d . -f1 | tr ',' ' ') )
      levels=( $(echo "$filter" | cut -d . -f2 | tr ',' ' ') )
      set +f
      echo "filter filter$i { "
      for facility in ${facilities[@]:0:${#facilities[@]}-1}; do
      	echo -e "\tfacility($facility) or "
      done
      if [ "${facilities[@]:${#facilities[@]}-1}" != '*' ]; then
        echo -e "\tfacility(${facilities[@]:${#facilities[@]}-1})"
      fi
      
      if [ "$levels" != '*' ]; then
        for level in ${levels[@]}; do
      	  if [ "$level" != '*' ]; then
      	    echo "or level($level)"
      	  fi
        done
      fi
      echo -e "\t;\n};"
      	
      if [ "${dest:0:1}" = "/" ]; then
      	echo "destination destination$i { file(\"$dest\"); };"
      else
        echo "destination destination$i { udp(\"$dest\" port(514)); };"
      fi
      echo "log { source(src); filter(filter$i); destination(destination$i); };"
      i=$(( $i + 1 )) 
    fi
  done
}
#************ syslogng_config

#****f* syslog-lib.sh/syslogng_start
#  NAME
#    syslogng_start
#  SYNOPSIS
#    function syslogng_start(chroot_path)
#  DESCRIPTION
#    Starts the syslogng as required
#  SOURCE
function syslog_ng_start {
	local chrootpath=$1
	local start_service_f="start_service_chroot $chrootpath"
	local syslog_sysconfig=$(repository_get_value "syslogsysconfig" "/etc/sysconfig/syslog")
	
    if [ -z "$chrootpath" ]; then
    	start_service_f=""
    fi

    if [ -f "$syslog_sysconfig" ] ; then
        . $syslog_sysconfig
    else
       syslogng_OPTIONS=""
       KLOGD_OPTIONS="-2"
    fi

    if [ -z "$SYSLOG_UMASK" ] ; then
       SYSLOG_UMASK=077;
    fi
    umask $SYSLOG_UMASK
   
    which syslog-ng >/dev/null 2>/dev/null
    if [ $? -eq 0 ]; then
    	$start_service_f syslog-ng $syslogng_OPTIONS
    fi
    which klogd > /dev/null 2>/dev/null
    if [ $? -eq 0 ]; then
    	$start_service_f klogd $KLOGD_OPTIONS
    fi
}
#******** syslogng_start

######################
# $Log: syslog-lib.sh,v $
# Revision 1.1  2009-09-28 13:08:10  marc
# initial revision
#