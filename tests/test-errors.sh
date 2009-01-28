clusterchanged
if [ $? -eq 0 ]; then
  error1="This is a testerror with variable USER=$USER"
  error2=$(errormsg err_test)
  if [ "$error1" != "$error2" ]; then
	"Testerrormsg returned wrong result \"$error1\" != \"$error2\"!!"
	return 1
  else
    return 0
  fi
fi