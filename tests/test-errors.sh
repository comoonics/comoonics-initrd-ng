if ! $(runonce); then
  echo -n "Testing errorlib for clutype: $clutype, rootfs=$rootfs"
  error1="This is a testerror with variable USER=$USER"
  error2=$(errormsg err_test)
  test "$error1" == "$error2"
  detecterror $? "Testerrormsg for clutype $clutype returned wrong result \"$error1\" != \"$error2\"!!" || echo -n " Failed"
  echo
fi