#!/bin/sh

DESTFILE=$1

if [ -z "$querymap" ]; then
  querymap=$(repository_get_value osrquerymap /etc/comoonics/querymap.cfg)
fi
if ! repository_has_key osrquerymap; then
  repository_store_value osrquerymap /etc/comoonics/querymap.cfg
fi
mkdir -p $(dirname ${DESTFILE}/$(osr_nodeid_file 1))
for nodeid in $(cc_get nodeids); do 
	osr_generate_nodevalues $nodeid $querymap > ${DESTFILE}/$(osr_nodeid_file ${nodeid})
	nodename=$(osr_get_nodename_by_id ${DESTFILE}/$(osr_nodeids_file) $nodeid ${DESTFILE}/$(osr_nodeid_file $nodeid))
#	echo "nodename: $nodename"
	[ -n "$nodename" ] && ln -f ${DESTFILE}/$(osr_nodeid_file ${nodeid}) ${DESTFILE}/$(osr_nodeid_file ${nodename})
done

unset DESTFILE nodeids nodename nodeid
