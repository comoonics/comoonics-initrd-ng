if ! runonce; then
  path=$(dirname $0)
  querymap="$path/../querymap.cfg"
  if ! test -f $querymap; then
    echo "Could not find querymap $querymap!!!" >&2
  else
    echo "Testing osrlib2"
    nodeid=1
    nodeconf=${path}/test/$(basename $(osr_nodeid_file $nodeid))
    nodeidsfile=${path}/test/$(basename $(osr_nodeids_file))
  
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
    result=$(osr_get_clustername $nodeid $nodeidsfile $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_clustername did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_nic_names"
    expectedresult="eth0 eth1"
    result=$(osr_get_nic_names $nodeid "" "" $nodeidsfile $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nic_names did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_nic_drivers"
    nic=$(echo $expectedresult | cut -f1 -d" ")
    expectedresult="e100"
    result=$(osr_get_nic_drivers $nodeid "" "$nic" $nodeidsfile $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nic_drivers did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_all_drivers"
    expectedresult="e100 tg3"
    result=$(osr_get_all_drivers $nodeid "" "" $nodeidsfile $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_all_drivers did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_drivers"
    expectedresult=""
    result=$(osr_get_drivers $nodeid "" "" $nodeidsfile $nodeconf)
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
    result=$(osr_get_nodeids $nodeidsfile)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nodeids did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_macs"
    expectedresult="00:0C:29:3B:XX:XX 01:0C:29:3B:XX:XX 00:0C:29:3C:XX:XX"
    result=$(osr_get_macs $nodeidsfile)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_macs did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_nodeid"
    expectedresult="1"
    result=$(osr_get_nodeid $nodeidsfile 01:0C:29:3B:XX:XX)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nodeid did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " 01:0C:29:3B:XX:XX => $result"
    expectedresult="2"
    result=$(osr_get_nodeid $nodeidsfile 00:0C:29:3C:XX:XX)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nodeid did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " 01:0C:29:3B:XX:XX => $result"
    echo

    echo -n "Testing function osr_get_nodename_by_id"
    expectedresult="gfs-node1"
    result=$(osr_get_nodename_by_id $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_nodename_by_id did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_rootvolume"
    expectedresult="/dev/VG_SHAREDROOT/LV_SHAREDROOT"
    result=$(osr_get_rootvolume $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_rootvolume did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_rootfs"
    expectedresult="gfs"
    result=$(osr_get_rootfs $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_rootfs did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_rootsource"
    expectedresult=""
    result=$(osr_get_rootsource $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_rootsource did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_userspace_procs"
    expectedresult=""
    result=$(osr_get_userspace_procs $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_userspace_procs did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_mountopts"
    expectedresult="noatime,nodiratime,noquota"
    result=$(osr_get_mountopts $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_mountopts did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_chroot_mountpoint"
    expectedresult="/var/comoonics/chroot"
    result=$(osr_get_chroot_mountpoint $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_chroot_mountpoint did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_chroot_fstype"
    expectedresult="ext3"
    result=$(osr_get_chroot_fstype $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_chroot_fstype did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    echo -n "Testing function osr_get_chroot_device"
    expectedresult="/dev/sda2"
    result=$(osr_get_chroot_device $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_chroot_device did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_chroot_mountopts"
    expectedresult=""
    result=$(osr_get_chroot_mountopts $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_chroot_mountopts did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_syslogserver"
    expectedresult="gfs-node1"
    result=$(osr_get_syslogserver $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_syslogserver did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_syslogfilter"
    expectedresult=""
    result=$(osr_get_syslogfilter $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_syslogfilter did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_scsifailover"
    expectedresult=""
    result=$(osr_get_scsifailover $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_scsifailover did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_get_netdevs"
    expectedresult="eth0 eth1"
    result=$(osr_get_netdevs $nodeidsfile 1 $nodeconf)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get_netdevs did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
         
    echo -n "Testing function osr_get"
    expectedresult="10.0.0.1"
    result=$(nodeconf=$nodeconf osr_get $nodeidsfile ip 1 eth0)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo -n " ip 1 eth0=$result"
    expectedresult="10.0.0.9"
    result=$(nodeconf=$nodeconf osr_get $nodeidsfile eth_name_ip 1 eth1)
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_get did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " eth_name_ip 1 eth1=$result"

    repository_store_value clutype osr      
    echo -n "Testing function cc_auto_netconfig"
    expectedresult="10.0.0.1::1.2.3.4:255.255.255.0::eth0:00-0C-29-3B-XX-XX:::yes:e100:MASTER=no:SLAVE=no:BONDING_OPTS=\"miimon=100:mode=1\""
    result=$(nodeconf=$nodeconf cc_auto_netconfig $nodeidsfile "" "eth0" "1")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "cc_auto_netconfig did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"

    repository_store_value clutype osr      
    echo -n "Testing function cc_auto_netconfig"
    expectedresult="10.0.0.9:::255.255.255.0::eth1:01-0C-29-3B-XX-XX:::yes:tg3:"
    result=$(nodeconf=$nodeconf cc_auto_netconfig $nodeidsfile "" "eth1" "1")
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "cc_auto_netconfig did not return \"$expectedresult\" for nodeid $nodeid but \"$result\" errorcode $errorcode"
    echo " $result"
        
    echo -n "Testing function osr_auto_hosts"
    expectedresult="10.0.0.1 gfs-node1"
    result=$(osr_auto_hosts $nodeidsfile $(dirname $nodeconf))
    errorcode=$?
    test "$result" = "$expectedresult"
    detecterror "$?" "osr_auto_hosts did not return \"$expectedresult\" but \"$result\" errorcode $errorcode"
    echo " $result"
  fi
fi