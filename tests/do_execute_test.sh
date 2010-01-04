#!/bin/bash
path=$(dirname $0)
testname=$1
testscript=$2
. $libdir/etc/std-lib.sh
. $testdir/lib/test-lib.sh
sourceLibs $libdir $clutype $distribution $shortdistribution
sourceRootfsLibs $libdir $rootfs $clutype $distribution $shortdistribution
test $trace -eq 1 && set -x
. $testscript
test $trace -eq 1 && set +x