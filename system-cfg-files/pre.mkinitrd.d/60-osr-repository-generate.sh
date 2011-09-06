#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

if [ -z "$querymap" ]; then
  querymap=$(repository_get_value osrquerymap /etc/comoonics/querymap.cfg)
fi
if ! repository_has_key osrquerymap; then
  repository_store_value osrquerymap /etc/comoonics/querymap.cfg
fi

nodeids=${$(cc_get nodeids):-1}
if [ "$nodeids" = "1" ]; then
	repository_store_value nodeid 1
fi
osr_create_nodeids_attrs $(repository_get_value clutype "") '"'$(repository_get_value cluster_conf "")'"' "$querymap" $nodeids
unset nodeids
