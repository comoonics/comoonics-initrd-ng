path=$(dirname $0)

runoncerootfs
if [ $? -ne 0 ]; then
  echo "Testing cluster-lib generic functions for rootfs: $rootfs, clutype: $clutype, distribution: $distribution."

  repository_store_value "cluster_conf" "$path/test/$clutype/cluster-conf-ok.xml"
  cluster_conf="$path/test/$clutype/cluster-conf-ok.xml"
  if ! [ -e "$cluster_conf" ]; then
  	echo "Cluster_conf $cluster_conf for clutype: $clutype does not exist. Breaking."
  else
    repository_store_value "nodeid" "1"
    nodeid=$(repository_get_value nodeid)
  
    _fsparameters=$(cc_get_valid_params)
    for _parameter in $_fsparameters; do
      if ! [ "$_parameter" = "rootfs" ]; then
        echo -n "Testing cc_getdefaults($_parameter)"
        expectedresult=$(cat $path/test/$clutype/cc_getdefaults_${_parameter} 2>/dev/null)
        result=$(cc_getdefaults $_parameter)
        test "$result" = "$expectedresult"
        detecterror $? "${clutype}_getdefaults $rootfs $_parameter failed. result: $result, expected: $expectedresult." || echo -n " Failed"
        echo " $result"
        result=""
        expectedresult=""
      fi
    done
    echo -n "Testing cc_get_nodename_by_id $nodeid"
    expectedresult="gfs-node1"
    result=$(cc_get_nodename_by_id $cluster_conf $nodeid)
    test "$result" = "$expectedresult"
    detecterror $? "cc_get_nodename_by_id $nodeid failed. result: $result, expected: $expectedresult." || echo -n " Failed"
    echo " $result"
   fi
fi