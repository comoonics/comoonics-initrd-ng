runonce() {
	eval test -n "\"\$${testname}_done\"" && eval test \$${testname}_done -eq 1
}
runoncerootfs() {
	eval test -n "\"\$${testname}_rootfs_done\"" && eval test \$${testname}_rootfs_done -eq 1
}
runonceclutype() {
	eval test -n "\"\$${testname}_clutype_done\"" && eval test \$${testname}_clutype_done -eq 1
}
runoncedistribution() {
	eval test -n "\"\$${testname}_distribution_done\"" && eval test \$${testname}_distribution_done -eq 1
}
skipme() {
	repository_store_value ${testname}_skip 1
}
isskipme() {
	repository_has_key ${testname}_skip && test $(repository_get_value ${testname}_skip) -eq 1
}
clusterchanged() {
	if [ -n "$lastclutype" ] && [ "$lastclutype" = "$clutype" ]; then
		return 1
	else
		return 0
    fi
}
rootfschanged() {
	if [ -n "$lastrootfs" ] && [ "$lastrootfs" = "$rootfs" ]; then
		return 1
	else
		return 0
    fi
}
distributionchanged() {
	if [ -n "$lastdistribution" ] && [ "$lastdistribution" = "$distribution" ]; then
		return 1
	else
		return 0
    fi
}
findlibs() {
   local lib="$1"
   [ -n "$2" ] && local libdir="$2"
   find $libdir -type f -path "*{lib}-lib.sh"
}
preparetest() {
   local clutype="$1"
   local rootfs="$2"
   local distribution="$3"
   local _distribution=""
   local _clutype=""
   local _rootfs=""
   
   exec 3>&1
   exec 4>&2
   
   # first source all libs
   local skip=0
   for lib in $(findlibs "*/etc/*" $libdir); do
   	  skip=0
   	  for _distribution in $distributions $cluster_types $root_filesystems; do
        test "$(basename $lib)"="${_distribution}-lib.sh" && skip=1
   	  done 
      if [ $skip -eq 0 ]; then
      	. $lib
      fi
   done
   if [ -n "$clutype" ]; then
      for lib in $(findlibs ${clutype} $libdir); do
        . $lib
      done
   fi 
   if [ -n "$rootfs" ]; then
      for lib in $(findlibs ${rootfs} $libdir); do
         . $lib
      done
   fi
   
   # including all distribution dependent files

   if [ -n "$distribution" ]; then
      for lib in $(find $libdir -path "*/lib/$distribution/*-lib.sh" -not -name "${clutype}-lib.sh" -not -name "${rootfs}-lib.sh"); do
         . $lib
      done
      if [ -n "$clutype" ]; then
         for lib in $(findlib $libdir -path "*/lib/$distribution/${clutype}-lib.sh"); do
           . $lib
         done
      fi 
      if [ -n "$rootfs" ]; then
         for lib in $(find $libdir -path "*/lib/$distribution/${rootfs}-lib.sh"); do
            . $lib
         done
      fi
   fi
}
detecterror() {
	local errorcode=$1
	local testing_errors=$(repository_get_value testing_errors)
	shift
	if [ $errorcode -ne 0 ]; then
		repository_store_value testing_errors $(( ${testing_errors} + $errorcode ))
		repository_append_value testing_errormsgs "
$*"
	fi
	return $errorcode
}
invdetecterror() {
	local errorcode=$1
	local testing_errors=$(repository_get_value testing_errors) 
	shift
	if [ $errorcode -eq 0 ]; then
		repository_store_value testing_errors $(( ${testing_errors} + 1 ))
		repository_append_value testing_errormsgs "
$*"
        return 1
	fi
	return  0
}
errormsg() {
	local testing_errors=$(repository_get_value testing_errors 0) 
	if [ ${testing_errors} -gt 0 ]; then
		echo "$testing_errors errors were detected. Errormessages are:"
		repository_get_value testing_errormsgs ""
	else
	    echo "All tests have successfully been executed."
    fi
    return ${testing_errors}
}
