if ! runonce; then
  path=$(dirname $0)
  querymap="$path/../querymap.cfg"
  if ! test -f $querymap; then
    echo "Could not find querymap $querymap!!!" >&2
  else
	[ -n "$ccs_xml_query" ] && repository_store_value ccs_xml_query $ccs_xml_query
    echo "Testing osrlib2"
    nodeid=1
#    nodeconf=${path}/test/$(basename $(osr_nodeid_file $nodeid))

    nodeids="1 2 4"
    cluster_conf="$path/test/gfs/cluster-conf-ok.xml"
    repository_store_value cluster_conf $cluster_conf
    repository_store_value osrquerymap $querymap
    [ -n "$ccs_xml_query" ] && repository_store_value ccs_xml_query $ccs_xml_query
    echo -n "Generating nodeidsfile for clusterconfiguration $cluster_conf nodeids: $nodeids"
    osr_create_nodeids_attrs "gfs" $cluster_conf $querymap $nodeids
	echo ""
    echo -n "Generating nodeid file for nodeid $nodeid"
    osr_generate_nodevalues $nodeid $querymap
    echo ".."
  
    echo -n "Testing function osr_resolve_element_alias"
    expectedresult="eth_name_ip"
    result=$(osr_resolve_element_alias ip)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_resolve_element_alias did not return \"$expectedresult\" but \"$result\" errorcode $errorcode"
    echo -n " ip=>$result"
    expectedresult="eth_name_ip"
    result=$(osr_resolve_element_alias eth_name_ip)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_resolve_element_alias did not return \"$expectedresult\" but \"$result\" errorcode $errorcode"
    echo -n " eth_name_ip=>$result"
    echo
  
    echo -n "Testing function osr_get_clustername"
    expectedresult="vmware_cluster"
    result=$(osr_get_clustername $nodeid "")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_clustername did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_nic_names"
    expectedresult="eth0 eth1"
    result=$(osr_get_nic_names $nodeid "" "" "")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nic_names did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_nic_drivers"
    nic=$(echo $expectedresult | cut -f1 -d" ")
    expectedresult="e100"
    result=$(osr_get_nic_drivers $nodeid "" "$nic" "")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nic_drivers did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_all_drivers"
    expectedresult="e100 tg3"
    result=$(osr_get_all_drivers $nodeid "" "" "")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_all_drivers did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_drivers"
    expectedresult=""
    result=$(osr_get_drivers $nodeid "" "" "")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_drivers did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_getdefaults"
    expectedresult="nfs"
    result=$(osr_getdefaults rootfs)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_getdefaults did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " rootfs=$result"
    expectedresult="nfs"
    result=$(osr_getdefaults root_fs)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_getdefaults did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " root_fs=$result"
    expectedresult="mapper"
    result=$(osr_getdefaults scsi_failover)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_getdefaults did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " scsi_failover=$result"
    result=$(osr_getdefaults scsifailover)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_getdefaults did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " scsifailover=$result"
    expectedresult="cluster"
    result=$(osr_getdefaults ip)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_getdefaults did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " ip=$result"
    echo

    echo -n "Testing function osr_get_nodeids"
    expectedresult="1 2 4"
    result=$(osr_get_nodeids "")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nodeids did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_macs"
    expectedresult="00:0C:29:3B:XX:XX 01:0C:29:3B:XX:XX 00:0C:29:3C:XX:XX"
    result=$(osr_get_macs "")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_macs did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_nodeid"
    expectedresult="1"
    result=$(osr_get_nodeid 01:0C:29:3B:XX:XX)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nodeid did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " 01:0C:29:3B:XX:XX => $result"
    expectedresult="2"
    result=$(osr_get_nodeid 00:0C:29:3C:XX:XX)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nodeid did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " 01:0C:29:3B:XX:XX => $result"
    echo

    echo -n "Testing function osr_get_nodename_by_id"
    expectedresult="gfs-node1"
    result=$(osr_get_nodename_by_id 1 )
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nodename_by_id did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_rootvolume"
    expectedresult="/dev/VG_SHAREDROOT/LV_SHAREDROOT"
    result=$(osr_get_rootvolume 1 )
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_rootvolume did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_rootfs"
    expectedresult="gfs"
    result=$(osr_get_rootfs 1 )
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_rootfs did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_rootsource"
    expectedresult=""
    result=$(osr_get_rootsource 1 )
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_rootsource did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_userspace_procs"
    expectedresult=""
    result=$(osr_get_userspace_procs 1 )
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_userspace_procs did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_mountopts"
    expectedresult="noatime,nodiratime,noquota"
    result=$(osr_get_mountopts 1 )
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_mountopts did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_chroot_mountpoint"
    expectedresult="/var/comoonics/chroot"
    result=$(osr_get_chroot_mountpoint 1)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_chroot_mountpoint did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_chroot_fstype"
    expectedresult="ext3"
    result=$(osr_get_chroot_fstype 1)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_chroot_fstype did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_chroot_device"
    expectedresult="/dev/sda2"
    result=$(osr_get_chroot_device 1)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_chroot_device did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_chroot_mountopts"
    expectedresult=""
    result=$(osr_get_chroot_mountopts 1)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_chroot_mountopts did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_syslogserver"
    expectedresult="gfs-node1"
    result=$(osr_get_syslogserver 1)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_syslogserver did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_syslogfilter"
    expectedresult=""
    result=$(osr_get_syslogfilter 1)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_syslogfilter did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_scsifailover"
    expectedresult=""
    result=$(osr_get_scsifailover 1 )
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_scsifailover did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_netdevs"
    expectedresult="eth0 eth1"
    result=$(osr_get_netdevs 1 )
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_netdevs did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
         
    echo -n "Testing function osr_get"
    expectedresult="10.0.0.1"
    result=$(osr_get ip 1 eth0)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " ip 1 eth0=$result"
    expectedresult="10.0.0.9"
    result=$(osr_get eth_name_ip 1 eth1)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " eth_name_ip 1 eth1=$result"

    echo -n "Testing function osr_get for filesystem"
    expectedresult="/var /var2"
    result=$(osr_get filesystem_dest $nodeid)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get for filesystem did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode" || echo "FAILED"
    echo " dests=$result"

    echo -n "Testing function osr_get for filesystem_var_source"
    for dest in "/var" "/var2"; do
       expectedresult="/cluster/cdsl/1/var"
       result=$(osr_get filesystem_dest_source $nodeid "$dest")
       errorcode=$?
       test "${result:0:${#expectedresult}}" = "$expectedresult"
       detecterror "$?" "osr_get for filesystem_var_source did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode" || echo "FAILED"
       echo -n " dests=$result"
    done
    echo

    repository_store_value clutype osr      
    echo -n "Testing function cc_auto_netconfig"
    expectedresult="10.0.0.1::1.2.3.4:255.255.255.0::eth0:00-0C-29-3B-XX-XX:::yes:e100:MASTER=no:SLAVE=no:BONDING_OPTS=\"miimon=100:mode=1\""
    result=$(cc_auto_netconfig "1" "eth0")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "cc_auto_netconfig did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    repository_store_value clutype osr      
    echo -n "Testing function cc_auto_netconfig"
    expectedresult="10.0.0.9:::255.255.255.0::eth1:01-0C-29-3B-XX-XX:::yes:tg3:"
    result=$(cc_auto_netconfig "1" "eth1")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "cc_auto_netconfig did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_auto_hosts"
    expectedresult="10.0.0.1 gfs-node1"
    result=$(osr_auto_hosts)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_auto_hosts did not return \"$expectedresult\" but \"$result\" errorcode $errorcode"
    echo " $result"
  fi
fi