#ccs_xml_query="../../comoonics-clustersuite/python/bin/com-queryclusterconf"
#workdir=$(dirname $0)/gfs
#export ccs_xml_query
#runonce
#if [ $? -eq 0 ]; then
#  echo "Testing ok cluster configurations (workdir: $workdir).."
#  for file in ${workdir}/cluster-conf*-ok.xml; do
#	  gfs_validate $file $xml_cmd || (echo "[FAILURE] validation of $file should be ok but is not. ERRORS: $errors" && false)
#	  detecterror $? $errors
#  done
#  echo "DONE"
#  echo "Testing not ok cluster configurations.."
#  for file in ${workdir}/cluster-conf*-notok.xml; do
#	  gfs_validate $file $xml_cmd && echo "[FAILURE] validation of $file should be not ok but is. ERRORS: $errors" && true
#	  invdetecterror $? $errors
#  done
#  echo "DONE"
#fi
