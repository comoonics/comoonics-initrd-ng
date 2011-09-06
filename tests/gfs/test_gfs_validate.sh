#ccs_xml_query="../../comoonics-clustersuite/python/bin/com-queryclusterconf"
#export ccs_xml_query
if ! isskipme; then
  if [ "$clutype" = "gfs" ]; then
    workdir=$(dirname $0)/test/gfs
    querymap="$path/../querymap.cfg"
    if ! test -f $querymap; then
      echo "Could not find querymap $querymap!!!" >&2
    else
      echo -n "Testing ok cluster configurations (workdir: $workdir, clutype=$clutype).."
      repository_store_value osrquerymap $querymap
      [ -n "$ccs_xml_query" ] && repository_store_value ccs_xml_query $ccs_xml_query
      for file in ${workdir}/cluster-conf*-ok.xml; do
        repository_store_value cluster_conf $file
	    gfs_validate $file $xml_cmd || (echo "[FAILURE] validation of $file should be ok but is not. ERRORS: $errors" && false)
	    detecterror $? $errors
      done
      echo "DONE"
      echo -n "Testing not ok cluster configurations.."
      for file in ${workdir}/cluster-conf*-notok.xml; do
        repository_store_value cluster_conf $file
	    gfs_validate && echo "[FAILURE] validation of $file should be not ok but is. ERRORS: $errors" && true
	    invdetecterror $? $errors
      done
      echo "DONE"
      skipme
    fi
  fi
fi
