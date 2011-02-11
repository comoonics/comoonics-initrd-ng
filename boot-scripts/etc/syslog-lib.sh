#
# $Id: syslog-lib.sh,v 1.9 2011-02-11 11:14:19 marc Exp $
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
    if [ -e /sbin/rsyslogd ] || [ -e /usr/sbin/rsyslogd ]; then
	   syslogtype="rsyslogd"
    elif [ -e /sbin/syslogd ] || [ -e /usr/sbin/syslogd ]; then
       syslogtype="syslogd"
    elif [ -e /sbin/syslog-ng ] || [ -e /usr/sbin/syslog-ng ]; then
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
       "rsyslogd") echo "/etc/rsyslog.conf";;
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
  
  [ -f "$syslog_conf_template" ] && cat $syslog_conf_template
  
  # Checking for normal syslog all others should be checked before so that this is the last resort syslog
  # this is obsolete we are writing to /dev/kmsg so we don't need this.
  #if [ -n "$debug" ]; then
  #  filters="$filters kern,daemon.*:/dev/console"
  #fi
  
  for dest in $dests; do
  	filter=$(echo $dest | cut -d: -f1)
  	dest=$(echo $dest | cut -d: -f2)
  	# default is all
  	[ "$dest" = "$filter" ] && filter="*.*"
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
#    function syslogd_start(chroot_path, no_klog)
#  DESCRIPTION
#    Starts the syslogd as required
#  SOURCE
function syslogd_start {
	local chrootpath=$1
	local no_klog=$2
	local start_service_f="start_service_chroot $chrootpath"
	local syslog_sysconfig=$(repository_get_value "syslogsysconfig" "/etc/sysconfig/syslog")
	
    if [ -z "$chrootpath" ]; then
    	start_service_f="exec_local"
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
    if [ $? -eq 0 ] && [ "$no_klog" != "no_klog" ]; then
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
  local debug=$(repository_get_value debug)
  local rsyslog_conf_template=$1
  shift
  local dests=$@
  local dest
  local filter
  
  #TODO: those values should be set from outside 
  local queuetype="FixedArray"
  local queuesize="1000"
  local queuediscardmark="500"
  
  local asyncoutputchannelsetting=$(cat <<EOF
# ActionQueue setup in order to not get stuck!
\$ActionQueueType ${queuetype}
\$ActionQueueSize ${queuesize}
# Begin discarding when this limit is reached
\$ActionQueueDiscardMark ${queuediscardmark}
EOF
)
  
  [ -f "$rsyslog_conf_template" ] && cat $rsyslog_conf_template
  
  for dest in $dests; do
  	filter=$(echo $dest | cut -d: -f1)
  	dest=$(echo $dest | cut -d: -f2)
  	# default is all
  	[ "$dest" = "$filter" ] && filter="*.*"
  	if [ -n "$filter" ] && [ -n "$dest" ]; then
      if [ "${dest:0:1}" = "/" ]; then
      	echo "${asyncoutputchannelsetting}"
      	echo "$filter $dest"
      	echo
      else
      	echo "${asyncoutputchannelsetting}"
        echo "$filter @$dest"
        echo
  	  fi
    fi
  done
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
	local no_klog=$2
	local start_service_f="start_service_chroot $chrootpath"
	local syslog_sysconfig=$(repository_get_value "syslogsysconfig" "/etc/sysconfig/rsyslog")
	
    if [ -z "$chrootpath" ]; then
    	start_service_f="exec_local"
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
   
    if [ "$no_klog" = "no_klog" ]; then
      syslogconf=$(default_syslogconf rsyslogd)
      cp $syslogconf ${syslogconf}.bak 2>/dev/null
      grep -v '^$ModLoad[[:space:]]*imklog.so' ${syslogconf}.bak 2>/dev/null > $syslogconf
      rm ${syslogconf}.bak 2>/dev/null
    fi
   
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
  local filtername
  local firstfilter=1
  local src="src_klog"
  
  [ -f "$syslog_conf_template" ] && cat $syslog_conf_template
  
  # Checking for normal syslog all others should be checked before so that this is the last resort syslog
  set -f
  if [ -n "$debug" ]; then
    filters="$filters kern,daemon.*:/dev/console"
  fi
  
  i=0
  for dest in $dests; do
  	if [ "$dest" = "no_klog" ] || [ "$dest" = "noklog" ]; then
  		src="src_noklog"
  	else
  	    filter=$(echo $dest | cut -d: -f1)
  	    dest=$(echo $dest | cut -d: -f2)
  	    # default is all
  	    [ "$dest" = "$filter" ] && filter="*.*"
  	    if [ -n "$filter" ] && [ -n "$dest" ]; then
            facilities=( $(echo "$filter" | cut -d . -f1 | tr ',' ' ') )
            levels=( $(echo "$filter" | cut -d . -f2 | tr ',' ' ') )
      
            if [ "$levels" != '*' ] || [ "$facilities" != '*' ]; then
                filtername="filter$i"
                echo "filter $filtername { "
                for facility in ${facilities[@]:0:${#facilities[@]}}; do
      	            if [ -n "$firstfilter" ] && [ "$facility" != '*' ]; then
      	                firstfilter=
      	                echo -e "\t facility($facility)"
      	            elif [ "$facility" != '*' ]; then
      	                echo -e "\t or facility($facility)"
      	            fi
                done

                if [ "$levels" != '*' ]; then
                    for level in ${levels[@]}; do
      	                if [ "$level" != '*' ]; then
      	    	             if [ -n "$firstfilter" ] && [ "$level" != '*' ]; then
                                 firstfilter=
      	                         echo -e "\t level(err..$level)"
      	    	             elif [ "$level" != '*' ]; then
      	    	                 echo -e "\t or level(err..$level)"
      	    	             fi
      	                fi
                    done
                fi
                echo -e "\t ;\n};"
            fi
      	
            if [ "${dest:0:1}" = "/" ]; then
      	        echo "destination destination$i { file(\"$dest\"); };"
            else
                echo "destination destination$i { udp(\"$dest\" port(514)); };"
            fi
            if [ -n "$filtername" ]; then
                echo "log { source($src); filter(filter$i); destination(destination$i); };"
            else
                echo "log { source($src); destination(destination$i); };"
            fi
            i=$(( $i + 1 ))
            filtername=
            filter=
            dest=
        fi
    fi
  done
  set +f
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
	local no_klog=$2
	local start_service_f="start_service_chroot $chrootpath"
	local syslog_sysconfig=$(repository_get_value "syslogsysconfig" "/etc/sysconfig/syslog")
	
    if [ -z "$chrootpath" ]; then
    	start_service_f="exec_local"
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
    if [ $? -eq 0 ] && [ "$no_klog" != "no_klog" ]; then
    	$start_service_f klogd $KLOGD_OPTIONS
    fi
}
#******** syslogng_start

######################
# $Log: syslog-lib.sh,v $
# Revision 1.9  2011-02-11 11:14:19  marc
# added no_klog parameter to syslogng_config.
#
# Revision 1.8  2011/02/08 08:43:54  marc
# syslog_ng_config:
# - rewrote the whole configuration generation for the filters to be working as expected.
# syslog_ng_start:
# - added support for no_klog parameter
#
# Revision 1.7  2011/02/02 09:17:56  marc
# - rsyslogd_config
#   - own implementation with queuing for every given output channel
#
# Revision 1.6  2011/01/12 09:05:06  marc
# - also autodetect syslog servers in /usr/sbin
#
# Revision 1.5  2011/01/11 14:58:37  marc
# - fixed bug in syslogd_config/rsyslogd_config because with only syslogserver the resulting syslogconfiguration would be wrong.
#
# Revision 1.4  2010/09/01 15:18:58  marc
#   - syslogd_config
#     - no explicit debug filter
#   - syslogd_start
#     - add parameter no_klog
#   - rsyslogd_start
#     - add parameter no_klog
#
# Revision 1.3  2010/06/29 18:59:13  marc
# default_syslogconf: right name of rsyslog.conf
#
# Revision 1.2  2010/06/25 12:28:04  marc
# - *_start: calling exec_local if no chroot given instead of nothing.
#
# Revision 1.1  2009/09/28 13:08:10  marc
# initial revision
#