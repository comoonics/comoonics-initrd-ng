#ccs_xml_query="../../comoonics-clustersuite/python/bin/com-queryclusterconf"
#export ccs_xml_query
if ! isskipme; then
  if [ "$clutype" = "gfs" ]; then
    workdir=$(dirname $0)/test/gfs
    echo -n "Testing ok cluster configurations (workdir: $workdir, clutype=$clutype).."
    for file in ${workdir}/cluster-conf*-ok.xml; do
	  gfs_validate $file $xml_cmd || (echo "[FAILURE] validation of $file should be ok but is not. ERRORS: $errors" && false)
	  detecterror $? $errors
    done
    echo "DONE"
    echo -n "Testing not ok cluster configurations.."
    for file in ${workdir}/cluster-conf*-notok.xml; do
	  gfs_validate $file $xml_cmd && echo "[FAILURE] validation of $file should be not ok but is. ERRORS: $errors" && true
	  invdetecterror $? $errors
    done
    echo "DONE"
    skipme
  fi
fi
