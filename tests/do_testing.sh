#!/bin/bash

usage() {
	cat<<EOF
`basename $0` [ [-h] | [-v] ] [test_file]*
  -h help 
  -d debug (even more chatty set -x before executing each testfile)
  -V show version
EOF
}
libdir=$(dirname $0)/../boot-scripts
testdir=$(dirname $0)
echo "Testdir: $testdir"

root_filesystems="gfs ocfs2 ext3 ext4 nfs"
cluster_types="gfs osr"
distributions="rhel5 sles10 sles11"

PYTHONPATH=$PYTHONPATH:../../comoonics-clustersuite/python/lib

trace=0
breakonerror=0
while getopts dhvVr:c:D:b option ; do
	case "$option" in
	    V) # version
		echo "$0 Version '$Revision $'"
		exit 0
		;;
	    h) # help
		usage
		exit 0
		;;
		d) #debug
		trace=1
		;;
		v) #verbose
		debug=1
		;;
		r) #rootfilesystems
	    root_filesystems="$OPTARG"
	    ;;
	    c) #clutypes
	    cluster_types="$OPTARG"
	    ;;
	    D) # distributions
	    distributions="$OPTARG"
	    ;;
	    b) # breakwhenerror
	    breakonerror=1
	    ;;
	    *)	    
		echo "Error wrong option." >&2
		usage
		exit 1
		;;
	esac
done
shift $(($OPTIND - 1))

if [ -z "$1" ]; then
  tests=$(find $testdir -type f -name "test*.sh" -not -path '*/lib/*')
else
  tests=$*
fi

if [ -z "$tests" ]; then
	echo "No tests found."
	exit 0
fi

shellopts=""

. $libdir/etc/std-lib.sh
. $libdir/etc/repository-lib.sh
. $testdir/lib/test-lib.sh

export testing_errors testing_errormsgs PYTHONPATH testing_errors libdir testdir root_filesystems cluster_types distributions
export trace debug

repository_clear

for testscript in $tests; do
  testname=$(basename $testscript)
  testname=${testname#test-}
  testname=${testname%.sh}
  testname=${testname//-/_}
  for distribution in $distributions; do
    shortdistribution=${distribution:0:4}
    repository_store_value distribution $distribution
    repository_store_value shortdistribution $shortdistribution
    
    for clutype in $cluster_types; do
      repository_store_value clutype $clutype
      for rootfs in $root_filesystems; do
        repository_store_value rootfs $rootfs
#          preparetest $clutype $rootfs $distribution
        echo_local_debug "Testing $testscript with distribution=$distribution, clutype=$clutype, rootfs=$rootfs"
        export rootfs clutype distribution shortdistribution lastrootfs lastclutype lastdistribution
           
        $testdir/do_execute_test.sh $testname $testscript
        if [ $breakonerror -eq 1 ] && [ $(repository_get_value testing_errors 0) -ne 0 ]; then
          errormsg
          exit 1
        else
          echo_local_debug "$testscript DONE"
        fi
        lastrootfs=$rootfs
        eval ${testname}_done=1
        eval ${testname}_rootfs_done=1
        eval export ${testname}_done ${testname}_rootfs_done
      done
      eval ${testname}_clutype_done=1
      eval export ${testname}_clutype_done
      eval unset  ${testname}_rootfs_done
      unset lastrootfs
      lastclutype=$clutype
    done
    eval unset ${testname}_clutype_done
    eval ${testname}_distribution_done=1
    eval export ${testname}_distribution_done
    unset lastclutype
    lastdistribution=$distribution
  done
  eval unset ${testname}_distribution_done
  unset lastdistribution
done
errormsg
#repository_clear
exit $?