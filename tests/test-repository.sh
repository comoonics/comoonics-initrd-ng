runonce
if [ $? -eq 0 ]; then
  REPOSITORY_PATH=/var/tmp
  REPOSITORY_PREFIX="__my_repository"
  REPOSITORY_DEFAULT="test_repository"
  echo "Testing repository functionality"
  repository_store_value test1 test1
  detecterror
  test -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${REPOSITORY_DEFAULT}
  detecterror "Repositoryfile ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${REPOSITORY_DEFAULT} does not exist."

  test1=$(repository_get_value test1)
  test "$test1" = "test1"
  detecterror "Repository get value returned value $test1 but it should return \"test1\"."
  
  repository_store_value test1 test2  
  test "$test1" = "test2"
  detecterror "Repository get value returned value $test1 but it should return \"test2\"."
  
  repository_store_value test2 test2
  
  values=$(repository_list_values)
  for value in $values; do
  	test "$value" = "test2"
  	detecterror "Repository list values returned a wrong value expected test2 got $value."
  done
  
  keys=$(repository_list_keys)
  for key in $keys; do
  	test "$key" = "test1" -o "$key" = "test2"
  	detecterror "Repository list keys returned a wrong value expected test2 got $key."
  done
  
#  items=$(repository_list_values)
#  for key in $keys; do
#  	test "$key" = "test1" -o "$key" = "test2"
#  	detecterror "Repository list keys returned a wrong value expected test2 got $key."
#  done
  
  repository_clear
  test -f ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${REPOSITORY_DEFAULT}
  invdetecterror "Repositoryfile ${REPOSITORY_PATH}/${REPOSITORY_PREFIX}${REPOSITORY_DEFAULT} does exists. But we've tryed to clear it away."
fi