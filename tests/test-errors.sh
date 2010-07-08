errorbin() {
	echo "This is an error" >&2
	return 1
}

if ! $(runonce); then
  echo -n "Testing errorlib for clutype: $clutype, rootfs=$rootfs"
  exec_local errorbin
  error1="This is a testerror with variable USER=$USER param1=param1
 Command: errorbin
 Errors: This is an error"
  error2="$(errormsg err_test param1)"
  test "$error1" = "$error2"
  detecterror $? "Testerrormsg for clutype $clutype returned wrong result \"$error1\" != \"$error2\"!!" || echo -n " Failed"
  echo
fi