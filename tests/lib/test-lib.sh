runonce() {
	eval test -n "\$${testname}_done" && eval test \$${testname}_done="1"
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
preparetest() {
   local clutype="$1"
   local rootfs="$2"
   local distribution="$3"
   
   exec 3>&1
   exec 4>&2
   
   # first source all libs
   for lib in $(find $libdir -path "*/etc/*-lib.sh" -not -name "${clutype}-lib.sh" -not -name "${rootfs}-lib.sh"); do
      . $lib
   done
   if [ -n "$clutype" ]; then
      for lib in $(find $libdir -path "*/lib/$distribution/${clutype}-lib.sh"); do
        . $lib
      done
   fi 
   if [ -n "$rootfs" ]; then
      for lib in $(find $libdir -path "*/lib/$distribution/${rootfs}-lib.sh"); do
         . $lib
      done
   fi
   
   # including all distribution dependent files

   if [ -n "$distribution" ]; then
      for lib in $(find $libdir -path "*/lib/$distribution/*-lib.sh" -not -name "${clutype}-lib.sh" -not -name "${rootfs}-lib.sh"); do
         . $lib
      done
      if [ -n "$clutype" ]; then
         for lib in $(find $libdir -path "*/lib/$distribution/${clutype}-lib.sh"); do
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
	shift
	if [ $errorcode -ne 0 ]; then
		testing_errors=$(( ${testing_errors} + $errorcode ))
		testing_errormsgs=${testing_errormsgs}"
$*
"
	fi
	return $testing_errors
}
invdetecterror() {
	local errorcode=$1
	shift
	if [ $errorcode -eq 0 ]; then
		testing_errors=$(( ${testing_errors} + 1 ))
		testing_errormsgs=${testing_errormsgs}"
$*
"
	fi
	return $testing_errors
}
errormsg() {
	if [ ${testing_errors} -gt 0 ]; then
		echo "$testing_errors errors were detected. Errormessages are: 
$testing_errormsgs"
	else
	    echo "All tests have successfully been executed."
    fi
    return ${testing_errors}
}