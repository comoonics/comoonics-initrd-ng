if ! runonce; then
  path=$(dirname $0)
  querymap="$path/../querymap.cfg"
  if ! test -f $querymap; then
    echo "Could not find querymap $querymap!!!" >&2
  else
    echo "Testing osrlib1"
  
    nodeid=1
    clustertype="gfs"
    repository_store_value clutype $clustertype
    cluster_conf="$path/test/$clustertype/cluster-conf-ok.xml"
    repository_store_value cluster_conf $cluster_conf
    repository_store_value osrquerymap $querymap
    [ -n "$ccs_xml_query" ] && repository_store_value ccs_xml_query $ccs_xml_query
    test -f $cluster_conf || echo "Could not find cluster configuration $cluster_conf"
    nodeids=$(${clustertype}_get nodeids)
    echo "Nodeids: $nodeids"

    echo -n "Generating nodeidsfile for clusterconfiguration $cluster_conf nodeids: $nodeids"
    osr_create_nodeids_attrs $clustertype $cluster_conf $querymap $nodeids
    test "1 2 4" = "$(repository_get_value nodeids)" &&
    test "00:0C:29:3B:XX:XX 01:0C:29:3B:XX:XX" = "$(repository_get_value 1_hwaddr)" &&
    test "00:0C:29:3C:XX:XX" = "$(repository_get_value 2_hwaddr)" &&
    test "none" = "$(repository_get_value 4_hwaddr)" 
    detecterror $? "Generating nodeids file failed." || echo -n " Failed"
    echo
    
    nodeid=$(echo $nodeids | cut -f1 -d" ")
    echo -n "Generating nodeid file for nodeid $nodeid"
    osr_generate_nodevalues $nodeid $querymap
    echo -n ".."
    nodeconf=${path}/test/osr-nodeidvalues-${nodeid}.conf
    err=0
    out=""
	while read line; do
		name=$(echo "$line" | cut -f1 -d=)
		value=$(echo "$line" | cut -f2- -d=)
#		echo "${nodeid}_$name"
		if [ "'$(repository_get_value "${nodeid}_$name")'" != "$value" ]; then
#			echo "$name $(repository_get_value ${nodeid}_$name) = $value"
			err=1
			out="${out}${nodeid}_$name '$(repository_get_value ${nodeid}_$name)' != $value
"
		fi
    done < $nodeconf
    detecterror $err "Generating nodeid file for nodeid $nodeid failed. Diff: $out" || echo -n " Failed"
    echo

	unset name
	unset value
	unset err
    unset cluster_conf
    unset nodeid
    unset clustertype
  fi
fi