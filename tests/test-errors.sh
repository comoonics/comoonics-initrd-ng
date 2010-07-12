errorbin() {
	echo "This is an error" >&2
	return 1
}

if ! $(runonce); then
  echo -n "Testing exec_local"
  exec_local errorbin > /dev/null
  rc=$?
  cmd1=$(repository_get_value exec_local_lastcmd)
  error1=$(repository_get_value exec_local_lasterror)
  test $rc -eq 1 && test "$error1" = "This is an error" && test "$cmd1" = "errorbin"
  detecterror $? "The command $cmd1 should return errorcode ($rc) and an error ($error1)."
  echo -n "Testing errorlib for clutype: $clutype, rootfs=$rootfs"
  error1="This is a testerror with variable USER=$USER param1=param1
 Command: errorbin
 Errors: This is an error"
  error2="$(errormsg err_test param1)"
  test "$error1" = "$error2"
  detecterror $? "Testerrormsg for clutype $clutype returned wrong result \"$error1\" != \"$error2\"!!" || echo -n " Failed"
  echo
fi