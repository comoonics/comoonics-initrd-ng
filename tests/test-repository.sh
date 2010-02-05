if ! runonce; then
#  REPOSITORY_PREFIX="my_repository"
  repository="test_repository"
  repository_clear $repository
  
  echo "Testing repository functionality"
  echo -n "Testing repository_store_value test1" 
  repository_store_value test1 test1 $repository
  detecterror $? "Could not store value test1 in test1."
  test -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.test1
  detecterror $? "Repositoryfile ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.test1 does not exist."
  echo

  echo -n "Testing repository_get_value"
  echo -n "..test2(default:test2)"
  test2=$(repository_get_value test2 test2 $repository)
  [ "$test2" = "test2" ]
  detecterror $? "Default value for test2 is not \"test2\" but \"$test2\""

  echo -n "..test1"
  test1=$(repository_get_value test1 "" $repository)
  test "$test1" = "test1"
  detecterror $? "Repository get value returned value $test1 but it should return \"test1\"."
  echo

  echo -n "Testing repository_store_value "
  echo -n "..test2"
  repository_store_value test2 "test2 test3" $repository
  test2=$(repository_get_value test2 "" $repository)
  test "$test2" = "test2 test3"
  detecterror $? "Repository get value returned value $test2 but it should return \"test2 test3\"."
  
#  echo -n "..test2"
#  repository_store_value test2 test2 $repository
  echo
  
  echo -n "Testing repository_list_values "
  eval values=( $(repository_list_values 0 $repository) )
  for value in ${values[@]}; do
  	echo -n "..$value"
  	test "$value" = "test2" || test "$value" = "test1"
  	detecterror $? "Repository list values returned a wrong value expected test2 got $value."
  done
  echo
  
  echo -n "Testing repository_list_keys "
  keys=$(repository_list_keys $repository)
  for key in $keys; do
  	echo -n "..$key"
  	test "$key" = "test1" -o "$key" = "test2"
  	detecterror $? "Repository list keys returned a wrong value expected test2 got $key."
  done
  echo
  
#  items=$(repository_list_values)
#  for key in $keys; do
#  	test "$key" = "test1" -o "$key" = "test2"
#  	detecterror "Repository list keys returned a wrong value expected test2 got $key."
#  done
  
#  echo -n "Testing repository_clear "
#  repository_clear $repository
#  ls -1 ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.* 2>/dev/null
#  invdetecterror $? "Repositoryfile ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${repository}.* does exists. But we've tryed to clear it away."
#  echo
fi