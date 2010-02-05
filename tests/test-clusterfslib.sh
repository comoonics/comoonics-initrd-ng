path=$(dirname $0)

if [ -z "$lastclutype" ] && [ -z "$lastdistribution" ] && [ -z "$lastclutype" ] && [ -n "$rootfs" ]; then
  echo "Testing clusterfslib generic functions for rootfs $rootfs, clutype:$clutype."

  repository_store_value "cluster_conf" "$path/test/$clutype/cluster-conf-ok.xml"
  cluster_conf="$path/test/$clutype/cluster-conf-ok.xml"
  querymap="$path/../querymap.cfg"
  if ! [ -e "$cluster_conf" ] || ! [ -e $querymap ]; then
  	echo "Cluster_conf $cluster_conf or $querymap for clutype: $clutype does not exist. Breaking."
  else
    repository_store_value "osrquerymap" "$querymap"
    repository_store_value "nodeid" "1"
    repository_store_value "nodename" "gfs-node1"
    nodeid=$(repository_get_value nodeid)
    nodename=$(repository_get_value nodename)

    echo -n "Testing chroot needed "
    expectedresult="$(cat $path/test/$rootfs/chroot_needed 2>/dev/null)"
    result="$(clusterfs_chroot_needed initrd)"
    test "$result" = "$expectedresult"
    detecterror $? "clusterfs_chroot_needed initrd failed for clutype: $clutype, rootfs: $rootfs. result: $result, expected: $expectedresult." || echo -n " Failed"
    echo " $result"
	
	for _parameter in "mountopts"; do
	  echo -n "Testing cc_get_${_parameter} $cluster_conf $nodename $nodeid"
      expectedresult=$(cat $path/test/$rootfs/cc_get_${_parameter} 2>/dev/null)
      result=$(cc_get_${_parameter} $cluster_conf $nodename $nodeid) 
      test $? -eq 0 && test "$result" = "$expectedresult"
      detecterror $? "cc_get_${_parameter} $cluster_conf $nodename $nodeid failed. result: $result, expected: $expectedresult." || echo -n " Failed"
      echo " $result"
    done
    
    echo -n "Testing function cc_get for filesystem"
    expectedresult="/var /var2"
    result=$(cc_get $nodeidsfile filesystem_dest $nodeid)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "cc_get for filesystem did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode" || echo "FAILED"
    echo " dests=$result"

    echo -n "Testing function cc_get for filesystem_var_source"
    for dest in "/var" "/var2"; do
       expectedresult="/cluster/cdsl/1/var"
       result=$(cc_get $nodeidsfile filesystem_dest_source $nodeid "$dest")
       errorcode=$?
       test "${result:0:${#expectedresult}}" = "$expectedresult"
       detecterror "$?" "cc_get for filesystem_var_source did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode" || echo "FAILED"
       echo -n " dests=$result"
    done
    echo
  
    _fsparameters="sourceserver lockmethod root mountopts scsifailover rootfsck mounttimes mountwait"
    for _parameter in $_fsparameters; do
      echo -n "Testing clusterfs_getdefaults($_parameter)"
      expectedresult=$(cat $path/test/$rootfs/clusterfs_getdefaults_${_parameter} 2>/dev/null)
      result=$(clusterfs_getdefaults $_parameter)
      test "$result" = "$expectedresult"
      detecterror $? "${rootfs}_getdefaults $_parameter failed. result: $result, expected: $expectedresult." || echo -n " Failed"
      echo " $result"
      result=""
      expectedresult=""
    
      echo -n "Testing getClusterParameter($_parameter)"
      expectedresult=$(cat $path/test/$rootfs/getClusterParameter_${_parameter} 2>/dev/null)
      result=$(getClusterParameter $_parameter $cluster_conf $nodeid $nodename)
      test "$result" = "$expectedresult"
      detecterror $? "getClusterParameter $clutype, $rootfs, $_parameter failed. result: $result, expected: $expectedresult." || echo -n " Failed"
      echo " $result"
      result=""
      expectedresult=""
    done
  fi
fi