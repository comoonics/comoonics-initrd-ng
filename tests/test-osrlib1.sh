if ! runonce; then
  path=$(dirname $0)
  querymap="$path/../querymap.cfg"
  if ! test -f $querymap; then
    echo "Could not find querymap $querymap!!!" >&2
  else
    echo "Testing osrlib1"
  
    nodeid=1
    echo -n "Testing osr_nodeid_file for nodeid \"$nodeid\""
    nodeconf=$(osr_nodeid_file $nodeid)
    expectedresult="/etc/conf.d/osr-nodeidvalues-$nodeid.conf"
    test "$nodeconf" = "$expectedresult"
    detecterror $? "Nodeconf for nodeid $nodeid is \"$nodeconf\" but \"$expectedresult\""
    echo " OK: $nodeconf"

    clustertype="gfs"
    repository_store_value clutype $clustertype
    cluster_conf="$path/test/$clustertype/cluster-conf-ok.xml"
    repository_store_value cluster_conf $cluster_conf
    test -f $cluster_conf || echo "Could not find cluster configuration $cluster_conf"
    nodeids=$(${clustertype}_get $cluster_conf $querymap nodeids)
    echo "Nodeids: $nodeids"
    tmpfile=$(tempfile)

    echo -n "Generating nodeidsfile for clusterconfiguration $cluster_conf nodeids: $nodeids, tmpfile: $tmpfile"
    osr_create_nodeids_file $clustertype $cluster_conf $querymap $nodeids > $tmpfile
    out=$(diff ${path}/test/osr-nodeids $tmpfile)
    detecterror $? "Generating nodeids file failed. Diff: $out" || echo -n " Failed"
    echo
    rm $tmpfile
    
    tmpfile=$(tempfile)
    nodeid=$(echo $nodeids | cut -f1 -d" ")
    echo -n "Generating nodeid file for nodeid $nodeid, tmpfile: $tmpfile"
    osr_generate_nodevalues $nodeid $querymap > $tmpfile
    nodeconf=${path}/test/$(basename $(osr_nodeid_file $nodeid))
    out=$(diff $nodeconf $tmpfile) 
    detecterror $? "Generating nodeid file for nodeid $nodeid failed. Diff: $out" || echo -n " Failed"
    echo
    rm $tmpfile
    unset cluster_conf
    unset nodeid
    unset clustertype
  fi
fi