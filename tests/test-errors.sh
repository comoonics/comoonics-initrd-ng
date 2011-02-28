errorbin() {
	echo "This is an error" >&2
	return 1
}

path=$(dirname $0)

if ! $(runonce); then
  echo -n "Testing exec_local"
  exec_local errorbin > /dev/null
  rc=$?
  cmd1=$(repository_get_value exec_local_lastcmd)
  error1=$(repository_get_value exec_local_lasterror)
  test $rc -eq 1 && test "$cmd1" = "errorbin" # && test "$error1" = "This is an error"
  detecterror $? "The command $cmd1 should return errorcode ($rc) and an error ($error1, $cmd1)."
  echo -n "Testing errorlib for clutype: $clutype, rootfs=$rootfs"
  error1="This is a testerror with variable USER=$USER param1=param1
 Command: errorbin
 Errors:"
  error2="$(errormsg err_test param1)"
  test "$error1" = "$error2"
  detecterror $? "Testerrormsg for clutype $clutype returned wrong result \"$error1\" != \"$error2\"!!" || echo -n " Failed"
  echo
  for errormsg in err_test err_cc_validate err_cc_wrongbootparamter err_clusterfs_fsck \
                  err_clusterfs_mount err_cc_nodeid err_cc_nodename err_hw_nicdriver \
                  err_nic_ifup err_nic_load err_nic_config err_storage_config err_storage_lvm \
                  err_cc_setup err_rootfs_device err_rootfs_mount err_fs_mount_cdsl err_cc_restart_service \
                  err_fs_device err_fs_mount; do
    expectedresult=$(cat $path/test/error/$errormsg.out)
    result=$(errormsg $errormsg param1 param2 param3 param4)
    test $? -eq 0 && test "$(echo $result)" = "$(echo $expectedresult)"
    detecterror $? "errormsg ${errormsg} failed. result: $result, expected: $expectedresult." || echo " Failed"
#    echo " $result"
  done
fi