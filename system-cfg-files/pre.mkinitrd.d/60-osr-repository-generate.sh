#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

if [ -z "$querymap" ]; then
  querymap=$(repository_get_value osrquerymap /etc/comoonics/querymap.cfg)
fi
if ! repository_has_key osrquerymap; then
  repository_store_value osrquerymap /etc/comoonics/querymap.cfg
fi

nodeids=$(cc_get nodeids)
nodeids=${nodeids:-1}
if [ "$nodeids" -eq 1 ]; then
	repository_store_value nodeid 1
fi
mkdir -p $(dirname ${DEST_PATH}$(osr_nodeids_file))
osr_create_nodeids_file $(repository_get_value clutype "") '"'$(repository_get_value cluster_conf "")'"' "$querymap" $nodeids > ${DEST_PATH}$(osr_nodeids_file)
unset nodeids
