#!/bin/sh

DESTFILE=$1

[ -z "$querymap" ] && querymap=/etc/comoonics/bootimage/query-map.cfg

echo > ${DESTFILE}/tmp/osr-nodeids
oldclutype=$(repository_get_value clutype)
repository_store_value clutype gfs
for nodeid in cc_get_nodeids; do 
	echo "$nodeid "$(cc_get_macs) >> ${DESTFILE}/tmp/osr-nodeids
	osr_generate_nodevalues $nodeid $querymap > ${DESTFILE}/etc/conf.d/osr-nodeidvalues-${nodeid}.conf
done
repository_store_value clutype $oldclutype

unset oldclutype
unset DESTFILE
