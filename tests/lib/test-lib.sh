function runonce {
	eval test -n "\$${testname}_done" && eval test \$${testname}_done="1"
}
function clusterchanged {
	if [ -n "$lastclutype" ] && [ "$lastclutype" = "$clutype" ]; then
		return 1
	else
		return 0
    fi
}
function rootfschanged {
	if [ -n "$lastrootfs" ] && [ "$lastrootfs" = "$rootfs" ]; then
		return 1
	else
		return 0
    fi
}
function distributionchanged {
	if [ -n "$lastdistribution" ] && [ "$lastdistribution" = "$distribution" ]; then
		return 1
	else
		return 0
    fi
}
function preparetest {
   local clutype="$1"
   local rootfs="$2"
   local distribution="$3"
   
   exec 3>&1
   exec 4>&2
   
   source ${libdir}/etc/sysconfig/comoonics

   source ${libdir}/etc/std-lib.sh
   source ${libdir}/etc/repository-lib.sh
   source ${libdir}/etc/chroot-lib.sh
   source ${libdir}/etc/boot-lib.sh
   source ${libdir}/etc/hardware-lib.sh
   source ${libdir}/etc/network-lib.sh
   source ${libdir}/etc/clusterfs-lib.sh
   source ${libdir}/etc/stdfs-lib.sh
   source ${libdir}/etc/defaults.sh
   source ${libdir}/etc/xen-lib.sh
   source ${libdir}/etc/errors.sh
   [ -e ${libdir}/etc/iscsi-lib.sh ] && source ${libdir}/etc/iscsi-lib.sh
   [ -e ${libdir}/etc/drbd-lib.sh ] && source ${libdir}/etc/drbd-lib.sh
   if [ -n "$clutype" ]; then
     source ${libdir}/etc/${clutype}-lib.sh
   fi

   if [ -n "$rootfs" ]; then
     [ -e ${libdir}/etc/${rootfs}-lib.sh ] && source ${libdir}/etc/${rootfs}-lib.sh
   fi

   # including all distribution dependent files
   if [ -n "$distribution" ]; then
     [ -e ${libdir}/etc/${distribution}/boot-lib.sh ] && source ${libdir}/etc/${distribution}/boot-lib.sh
     [ -e ${libdir}/etc/${distribution}/hardware-lib.sh ] && source ${libdir}/etc/${distribution}/hardware-lib.sh
     [ -e ${libdir}/etc/${distribution}/network-lib.sh ] && source ${libdir}/etc/${distribution}/network-lib.sh
     [ -e ${libdir}/etc/${distribution}/clusterfs-lib.sh ] && source ${libdir}/etc/${distribution}/clusterfs-lib.sh
     if [ -n "$clutype" ]; then
       [ -e ${libdir}/etc/${distribution}/${clutype}-lib.sh ] && source ${libdir}/etc/${distribution}/${clutype}-lib.sh
     fi
     if [ -n "$rootfs" ]; then
       [ -e ${libdir}/etc/${distribution}/${rootfs}-lib.sh ] && source ${libdir}/etc/${distribution}/${rootfs}-lib.sh
     fi
     [ -e ${libdir}/etc/${distribution}/xen-lib.sh ] && source ${libdir}/etc/${distribution}/xen-lib.sh
     [ -e ${libdir}/etc/${distribution}/iscsi-lib.sh ] && source ${libdir}/etc/${distribution}/iscsi-lib.sh
     [ -e ${libdir}/etc/${distribution}/drbd-lib.sh ] && source ${libdir}/etc/${distribution}/drbd-lib.sh
	 [ -e ${libdir}/etc/${distribution}/errors.sh ] && source ${libdir}/etc/${distribution}/errors.sh
   fi
}
function detecterror {
	if [ $? -ne 0 ]; then
		testing_errors=$(( ${testing_errors} + $? ))
		testing_errormsgs=${testing_errormsgs}"
$*
"
	fi
	return $testing_errors
}
function invdetecterror {
	if [ $? -eq 0 ]; then
		testing_errors=$(( ${testing_errors} + 1 ))
		testing_errormsgs=${testing_errormsgs}"
$*
"
	fi
	return $testing_errors
}
function errormsg {
	if [ ${testing_errors} -gt 0 ]; then
		echo "$testing_errors errors were detected. Errormessages are: 
$testing_errormsgs"
	else
	    echo "All tests have successfully been executed."
    fi
    return ${testing_errors}
}