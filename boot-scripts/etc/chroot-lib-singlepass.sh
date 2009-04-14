#
# $Id: chroot-lib-singlepass.sh,v 1.1 2009-04-14 14:59:34 marc Exp $
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
#    chroot-lib.sh
#    $id$
#  DESCRIPTION
#    Library of methods needed to create and manage chroot environments
#    This library is also used to create initrd environments
#*******

#****f* create-gfs-initrd-lib.sh/extract_rpm
#  NAME
#    extract_rpm
#  SYNOPSIS
#    function extract_rpm(rpmfile, root) {
#  DESCRIPTION
#    Extracts the given rpmfile to the given root
#  IDEAS
#  SOURCE
#
function extract_rpm() {
	 local rpm=$1
	 local dest=$2
	 (cd $dest &&
	  rpm2cpio $rpm | cpio -ivdum)
}
#************ extract_rpm

#****f* chroot-lib.sh/extract_installed_rpm
#  NAME
#    extract_installed_rpm
#  SYNOPSIS
#    function extract_installed_rpm(rpmfile, root, filter) {
#  DESCRIPTION
#    Extracts the found file from rpm rpmfile to the given root
#    If a filter is given only files that match the filter will be copied
#    filter also implies that an expensive -a option is added
#  IDEAS
#    Run rpm -ql rpmfile and copy all listed files to root.
#  SOURCE
#
function extract_installed_rpm() {
  local rpm=$1
  local dest=$2
  local filter1=$3
  local filter2=$4
  local qopt=""
  rpm -q $rpm >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Cannot find rpm \"$rpm\". Skipping." >&2
    return 1
  fi

  if [ "$filter1" = "." ]; then
	filter1=""
  fi

  if [ -n "$filter1" ]; then
  	qopt="-a"
  fi

  if [ -z "$filter2" ]; then
  	filter2="^\$"
  fi

  pushd $dest >/dev/null
  for file in $(rpm -ql $qopt $rpm | grep -e "$filter1" | grep -v "$filter2"); do
  	#echo "rpm : $rpm, $file" >&2
    [ ! -e ${dest}$(dirname $file) ] && mkdir -p ${dest}$(dirname $file)
    if [ -d $file ]; then
      mkdir ${dest}$file 2>/dev/null
    else
      cp -a $file ${dest}$(dirname $file)
    fi
  done
  popd >/dev/null
}
#************ extract_installed_rpm

#****f* chroot-lib.sh/get_filelist_from_installed_rpm
#  NAME
#    get_filelist_from_installed_rpm
#  SYNOPSIS
#    function get_filelist_from_installed_rpm(rpmfile, filter) {
#  DESCRIPTION
#    returns a filelist from rpmfile
#    If a filter is given only files that match the filter will be given
#    filter also implies that an expensive -a option is added
#  IDEAS
#  SOURCE
#
function get_filelist_from_installed_rpm() {
  local rpmpackages=( )
  local globalfilterfile="$1"
  local verbose="$2"

  # this is an ugly hack!!!!!
  # We'll declare rpmnegfilters and rpmfilters as global variables to use them in other functions
  # Any better ideas are greatly appreciated!
  globalfilters=$(get_global_filters $globalfilterfile $verbose) 
  rpmfilters=( )
  rpmnegfilters=( )
  local rpmprefix="RPMPACKAGE:"
  local i=0
  declare -a rpmpackages
  declare -a rpmfilters
  declare -a rpmnegfilters
  
  while read line; do
    local rpm=$(echo $line | cut -d: -f 1)
    local filter1=$(echo $line | cut -s -d: -f 2)
    local filter2=$(echo $line | cut -s -d: -f 3)
    local qopt="--queryformat=${rpmprefix}%{NAME}\n"

# Do we need that one? Don't we get an apropriate output below as well?
#    rpm -q $rpm >/dev/null 2>&1
#    if [ $? -ne 0 ]; then
#      echo "Cannot find rpm \"$rpm\". Skipping." >&2
#      return 1
#    fi

    if [ "$filter1" = "." ]; then
      filter1=".*";
    fi
    
    if [ -z "$filter1" ]; then 
      filter1=".*"
    fi

# Let's always use -a
#    if [ -n "$filter1" ]; then
#      qopt="-a"
#    fi

    if [ -z "$filter2" ]; then
      filter2="^\$"
    fi
    
    rpmpackages[$i]=$rpm
    rpmfilters[$i]="$filter1"
    rpmnegfilters[$i]=$filter2
    i=$(( $i + 1 ))
  done
  
  if [ -n "$verbose" ]; then
  	echo "RPMPackages:   ${rpmpackages[@]}"
  	echo "RPMFilters:    ${rpmfilters[@]}"
  	echo "RPMNegFilters: ${rpmnegfilters[@]}"
  fi
  
  rpm -q $qopt -l ${rpmpackages[@]} | get_all_files_from_rpm $rpmprefix "$verbose" ${rpmpackages[@]}
  #for filename in $(rpm -ql $qopt $rpm | grep -e "$filter"); do
  # get all rpms that match filter without docs
  #for filename in $(rpm -q $qopt $rpm --dump | grep -e "$filter1" | grep -v "$filter2" | awk ' $9~0 {print $1}'); do
  #	if [ -n "$filename" ] && [ ${filename:0:5} != "/proc" ] && [ ${filename:0:4} != "proc" ]; then
  #	   echo $filename
  #	   get_dependent_files $filename
  #	fi
  #done
}
#************ get_filelist_from_installed_rpm

#****f* chroot-lib.sh/get_all_files_from_rpm
#  NAME
#    get_all_files_from_rpm
#  SYNOPSIS
#    function get_all_files_from_rpm(rpmfile, filter) {
#  DESCRIPTION
#  IDEAS
#  SOURCE
#
function get_all_files_from_rpm() {
	local rpmprefix="$1"
	local verbose="$2"
	local rpms=${@:2}
	local rpmfilter=""
	local rpmnegfilter=""
	local rpmname=""
	local line=""
	local index=0
	
	while read line; do
		if [ "$rpmprefix" = "${line:0:${#rpmprefix}}" ]; then
	      rpmname=${line#${rpmprefix}}
	      index=$(get_index_from_array $rpmname $rpms)
	      # those are globally defined as arrays cannot be easily given as parameter to functions
	      rpmfilter=${rpmfilters[$index]}
          rpmnegfilter=${rpmnegfilters[$index]}
	      [ -z "$rpmfilter" ] && rpmfilter=".*"
	      [ "$rpmfilter" = "." ] && rpmfilter=".*"
	      [ "$rpmnegfilter" = "" ] && rpmnegfilter="^\$"
        elif [ -e "$line" ]; then
	      # We suppose that all rpmname, rpmfilter and rpmnegfilter at set at this point
          local filename=$line 
          if [ -n "$filename" ] && [ ${filename:0:5} != "/proc" ] && [ ${filename:0:4} != "proc" ]; then
             echo $filename | grep -e "$rpmfilter" | grep -v -e "$rpmnegfilter" # >/dev/null 2>/dev/null
             ret=$?
             if [ $ret -eq 0 ]; then
             	echo $filename | apply_global_filters > /dev/null 2>/dev/null
             	ret=$?
             fi
             if [ $ret -eq 0 ]; then
             	echo $filename
                #get_dependent_files $filename
             fi
          fi
        else
          echo "Could not handle rpmoutput \"$line\"." >&2
        fi
    done
}
#********* get_all_files_from_rpm

#****f* create-gfs-initrd-lib.sh/extract_all_rpms
#  NAME
#    extract_all_rpms
#  SYNOPSIS
#    function extract_all_rpms(rpm_listfile, root, rpmdir) {
#  DESCRIPTION
#    Calls extract_rpm/extract_installed for all files listed in
#    rpm_listfile
#  IDEAS
#  SOURCE
#
function extract_all_rpms() {
  local rpm_listfile=$1
  local root=$2
  local verbose=$3
  local -a rpmdef
  local rpm
  if [ ! -e "$rpm_listfile" ]; then
    echo "Cannot find rpmlistfile \"$rpm_listfile\". Exiting." >&2
    return 1
  fi

   $rpm_listfile $verbose | while read line; do
  	rpmdef=( $line )
  	rpm=${rpmdef[0]}
	filter1=${rpmdef[1]}
	filter2=${rpmdef[2]}
    if [ ${rpm:0:1} != '#' ]; then
      if [ -f $rpm ]; then
        extract_rpm $rpm $root
      else
      	[ -n "$verbose" ] && echo "$rpm with filter $filter1 and ! $filter2"
        extract_installed_rpm $rpm $root $filter1 $filter2
      fi
    fi
  done
}
#************ extract_all_rpms

#****f* chroot-lib.sh/get_filelist_from_rpms
#  NAME
#    get_filelist_from_rpms
#  SYNOPSIS
#    get_filelist_from_rpms(rpm_listfile, [verbose]) {
#  DESCRIPTION
#    Calls extract_rpm/extract_installed for all files listed in
#    rpm_listfile
#  IDEAS
#  SOURCE
#
function get_filelist_from_rpms() {
  local rpm_listfile=$1
  local globalfilters_file=$2
  local verbose=$3
  local -a rpmdef
  local rpm
  if [ ! -e "$rpm_listfile" ]; then
    echo "Cannot find rpmlistfile \"$rpm_listfile\". Exiting." >&2
    return 1
  fi

  local rpms=""
  resolve_file $rpm_listfile $verbose | while read line; do
  	rpmdef=( $line )
  	rpm=${rpmdef[0]}
	filter1=${rpmdef[1]}
	filter2=${rpmdef[2]}
    if [ ${rpm:0:1} != '#' ]; then
      [ -n "$verbose" ] && echo "$rpm with filter $filter1 and ! $filter2" >&2
      echo "$rpms $rpm:$filter1:$filter2"
    fi
  done | get_filelist_from_installed_rpm $globalfilters_file "$verbose"
}
#************ get_filelist_from_rpms

#****f* chroot-lib.sh/get_global_filters
#  NAME
#    get_global_filters
#  SYNOPSIS
#    get_global_filters(globalfilters_file, [verbose]) {
#  DESCRIPTION
#    Gets all globally set filters from files
#  IDEAS
#  SOURCE
#
function get_global_filters() {
	local filterfile=$1
	local verbose=$2
	
    resolve_file $filterfile
}
#************ get_global_filters

#****f* chroot-lib.sh/apply_global_filters
#  NAME
#    apply_global_filters
#  SYNOPSIS
#    apply_global_filters() {
#  DESCRIPTION
#    applies all global filters to stdin line by line
#  IDEAS
#  SOURCE
#
function apply_global_filters {
	local line=""
	local applied=0
	local applied2=0
	while read line; do
		if [ -z "$globalfilters" ] || [ "$globalfilters" = "" ]; then
			echo $line
		else	
			applied=0
			for filter in "$globalfilters"; do
				echo $line | grep -v "$filter" 1>/dev/null 2>/dev/null
				if [ $? -ne 0 ]; then
					applied=1
					applied2=1
				fi
			done
			if [ $applied -ne 1 ]; then
				echo $line
			fi
		fi
	done
	if [ $applied2 -eq 1 ]; then
		return 1
	fi
}
#************ apply_global_filters


#****f* create-gfs-initrd-lib.sh/resolve_file
#  NAME
#    resolve_file
#  SYNOPSIS
#    function resolve_file() {
#  MODIFICATION HISTORY
#  DOCUMENTATION
#    Takes a filename as argument and resolves it be ignoring comments and including @include tags.
#  SOURCE
#
function resolve_file {
  local filename=$1
  local verbose=$2
  while read line; do
    if [ -n "$line" ] && [ ${line:0:1} != '#' ]; then
      if [ ! -e "$line" ] && [ "${line:0:8}" = '@include' ]; then
        declare -a aline
        aline=( $(echo $line) )
	    include=${aline[@]:1}
	    if [ -d "$include" ]; then
	      for file in ${include}/*; do
	        [ -n "$verbose" ] && echo "Including file $file" >&2
            resolve_file $file $verbose
          done
        elif [ -e "$include" ]; then
	      resolve_file $include $verbose
	    else
          if [ "${include:0:2}" = '$(' ] || [ "${include:0:1}" = '`' ]; then
	        [ -n "$verbose" ] && echo "Eval $include"  >&2
	        include=$(echo ${include/#\$\(/})
	        include=$(echo ${include/#\`/})
	        include=$(echo ${include/%\)/})
	        files=$(eval "$include")
          else
            files="$include"
	      fi
          for file in $files; do
  	        [ -n "$verbose" ] && echo "Including file $file" >&2
            resolve_file $file $verbose
          done
        fi
      else
        [ -n "$verbose" ] && echo "line $line" >&2
        echo "$line"
      fi
    fi
  done <$filename
}
#************resolve_file

##****f* chroot-lib.sh/get_index_from_array
#  NAME
#    get_index_from_array
#  SYNOPSIS
#    function get_index_from_array(name, array) {
#  DESCRIPTION
#    returns the index where the name is found in array. else -1
#  IDEAS
#  SOURCE
#
function get_index_from_array() {
	local name=$1
	local array=( ${@:2} )
#	echo "array ${array[1]} ${#array[@]}"
#	declare -a array
	local i=0
	
	for i in $(seq 0 $(( ${#array[@]} - 1 )) ); do
	  if [ "$name" = "${array[$i]}" ]; then
	  	echo $i
	  	return 0
	  fi
	done
	echo -1
	return -1
}
#************ get_index_from_array

##****f* chroot-lib.sh/get_dependent_files
#  NAME
#    get_dependent_files
#  SYNOPSIS
#    function get_dependent_files(filename) {
#  DESCRIPTION
#    checks if the file is executable.
#    If so it returns all dependent libraries with path as a stringlist.
#  IDEAS
#  SOURCE
#
function get_dependent_files() {
  filename=$1
  if [ -n "$filename" ] && [ ${filename:0:5} != "/proc" ] && [ ${filename:0:4} != "proc" ]; then
    # file is a symbolic link
    if [ -L $filename ]; then
      local newfile=`ls -l $filename | sed -e "s/.* -> //"`
      if [ -n "$newfile" ] && [ ${newfile:0:5} != "/proc" ] && [ ${newfile:0:4} != "proc" ]; then
        if [ "${newfile:0:1}" != "/" ]; then
          echo `dirname $filename`/$newfile
        else
          echo $newfile
        fi
      fi
    # file is executable and not directory
    elif [ -x $filename -a ! -d $filename ]; then
      ldd $filename > /dev/null 2>&1
      if [ $? = 0 ]; then
#      local newfiles=`ldd $filename | sed -e "s/^.*=> \(.*\) (.*).*$/\1/" | sed -e "s/^.*statically linked.*$//"`
        local newfiles=$(ldd $filename | awk '
$3 ~ /^\// { print $3; }
$1 ~ /^\// && $3 == "" { print $1; }
')
        for newfile in $newfiles; do
           echo $newfile
           if [ -L $newfile ]; then
             local _newfile=$(ls -l $newfile | awk '$11 != "" { print $11; }')
             if [ -n "$newfile" ] && [ ${newfile:0:5} != "/proc" ] && [ ${newfile:0:4} != "proc" ]; then
               if [ "${_newfile:0:1}" != "/" ]; then
                 echo $(dirname $newfile)/$_newfile
               else
                 echo $_newfile
               fi
             fi
           fi
        done
      fi
    fi
  fi
}
#************ get_dependent_files

#****f* chroot-lib.sh/get_all_depfiles
#  NAME
#    get_all_depfiles
#  SYNOPSIS
#    function get_all_depfiles {
#  DEPRECATED
#  DESCRIPTION
#   Get all depfiles gets all depfiles from the given file
#   That means if there is a @include tag those files are also returned
#  SOURCE
#
function get_all_depfiles {
  local $basefile=$1;
  local $verbose=$2;

  echo $basefile
  for sub_dep_file in $(grep "^@include" $basefile | awk '{print $2;}'); do
    [ -e "$sub_dep_file" ] && get_all_depfiles $sub_dep_file $verbose
  done
}
#************ get_all_depfiles

#****f* chroot-lib.sh/get_all_files_dependent
#  NAME
#    get_all_files_dependent
#  SYNOPSIS
#    function get_all_files_dependent() {
#  MODIFICATION HISTORY
#  DOCUMENTATION
#    Takes a filename as argument and pipes all files listed in this file to
#    get_dependent_files.
#  SOURCE
#
function get_all_files_dependent() {
  local filename=$1
  local verbose=$2
  local line=""
  local dirname=""
  local files=""

  while read line; do
	# FIXME:
	#   if [ "${line:0:1}" != '#' ]; then does not work. Don't know WHY the shit!!
	#
	if [ -n "${line:0:1}" ]; then
      if [ ${line:0:1} != '#' ]; then
        if [ ! -e "$line" ] && [ "${line:0:7}" = '@perlcc' ]; then
          # take next as filename and compile
          echo "Skipping line $todir..." >&2
	      line=${line:8}
	      local filename=`which $line 2>/dev/null`
	      if [ -z $filename ]; then
	        filename=$line
	      fi
	      #echo $filename
	      [ -n "$verbose" ] && echo "Taking perl file $filename..." >&2
	      dirname=`dirname $filename`
	      create_dir ${mountpoint}$dirname
	      perlcc_file $filename ${mountpoint}$filename
	      get_dependent_files ${mountpoint}$filename
        elif [ ! -e "$line" ] && [ "${line:0:4}" = '@map' ]; then
          declare -a aline
          aline=( $(echo $line | tr '&' ' ') )
	      mapdir=${aline[2]}
          line=${aline[1]}
          [ -n "$verbose" ] && echo "Mapping $line to $mapdir" >&2
	      local filename=`which $line 2>/dev/null`
	      if [ -z $filename ]; then
	        filename=$line
  	      fi
	      echo "@map&$filename&$mapdir"
          # get_dependent_files $filename
        elif [ ! -e "$line" ] && [ "${line:0:8}" = '@include' ]; then
          declare -a aline
          aline=( $(echo $line) )
	      include=${aline[@]:1}
	      if [ -d "$include" ]; then
	        for file in ${include}/*; do
	          [ -n "$verbose" ] && echo "Including file $file" >&2
              get_all_files_dependent $file $verbose
            done
          elif [ -e "$include" ]; then
	        get_all_files_dependent $include $verbose
	      else
            if [ "${include:0:2}" = '$(' ] || [ "${include:0:1}" = '`' ]; then
	          [ -n "$verbose" ] && echo "Eval $include"  >&2
	          include=$(echo ${include/#\$\(/})
	          include=$(echo ${include/#\`/})
	          include=$(echo ${include/%\)/})
	          files=$(eval "$include")
            else
              files="$include"
	        fi
            for file in $files; do
  	          [ -n "$verbose" ] && echo "Including file $file" >&2
              get_all_files_dependent $file $verbose
            done
          fi
        else
	      local filename=`which $line 2>/dev/null`
	      if [ -z $filename ]; then
	        filename=$line
	      fi
	      echo $filename
	      get_dependent_files $filename
        fi
      fi
    fi
  done <$filename
}
#************ get_all_files_dependent

#****f* chroot-lib.sh/get_min_modules
#  NAME
#    get_min_modules
#  SYNOPSIS
#    function get_min_modules(module*) {
#  MODIFICATION HISTORY
#  DOCUMENTATION
#    Returns a list of modules needed as minimum for the initrd. Those are modules loaded by
#    by this node, modules in /etc/modprobe.conf and modules (@driver) specified in the 
#    cluster configuration 
#  SOURCE
#
function get_min_modules() {
	local loaded_modules="/proc/modules"
	echo $@
    awk '{ sub("_", "[_-]", $1); print $1; }' $loaded_modules
	awk '$1="alias" { print $3; }' $modules_conf
	cc_get_all_drivers "" "" "" $(repository_get_value cluster_conf)
	if clusterfs_blkstorage_needed $(repository_get_value rootfs); then
		storage_get_drivers $(repository_get_value cluster_conf)
	fi
	get_default_drivers
}
#************ get_min_modules

#####################
# $Log: chroot-lib-singlepass.sh,v $
# Revision 1.1  2009-04-14 14:59:34  marc
# lets keep this for the first
#
