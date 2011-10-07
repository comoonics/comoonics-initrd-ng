#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

if [ -f $(repository_get_value cluster_conf /etc/cluster/cluster.conf) ] && 
   [ -e $(repository_get_value ccs_xml_query /usr/bin/com-queryclusterconf) ] &&  
   [ "$(repository_get_value clutype)" = "gfs" ]; then
  if [ -z "$querymap" ]; then
    querymap=$(repository_get_value osrquerymap /etc/comoonics/querymap.cfg)
  fi
  if ! repository_has_key osrquerymap; then
    repository_store_value osrquerymap /etc/comoonics/querymap.cfg
  fi

  if $(repository_get_value clutype)_get -q com_info &>/dev/null; then
  	nodeids=${$(cc_get nodeids):-1}
    if [ "$nodeids" = "1" ]; then
	  repository_store_value nodeid 1
    fi
    osr_create_nodeids_attrs $(repository_get_value clutype "") "$(repository_get_value cluster_conf "")" "$querymap" $nodeids
    for nodeid in $nodeids; do
      osr_generate_nodevalues $nodeid "$querymap"
    done
    unset nodeid
    unset nodeids
  fi
else
  repository_store_value nodeids "$(cc_get_nodeids)"
fi
