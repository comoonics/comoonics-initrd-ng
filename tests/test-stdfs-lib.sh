runonce
if [ $? -eq 0 ]; then
  MOUNTS="/dev1 /a fstype1 rest
/dev2 /a/b fstype2 rest
/dev3 /a/b/c fstype3 rest
/dev4 /a/c fstype4 rest
/dev5 /b fstype5 rest
/dev6 /b/a fstype6 rest
"
  echo "Testing stdfs-lib.."

  echo -n "Testing ismounted.."
  for path in /a /b /b/a; do
    is_mounted $path
    detecterror $? "Could not find mounted fs $path"
  done
  for path in /d /b/c /a/b/d; do 
  	is_mounted $path
  	invdetecterror $? "Path $path seems to be mounted but is not."
  done
  echo "OK"
  
  echo -n "Testing get_dep_filesystems"
  out=$(get_dep_filesystems /a)
  result="/a/c
/a/b/c
/a/b"
  [ "$out" = "$result" ]
  detecterror $? "get_dep_filesystems /a: $out != $result"

  out=$(get_dep_filesystems /a /a/b)
  result="/a/c"
  [ "$out" = "$result" ]
  detecterror $? "get_dep_filesystems /a /a/b: $out != $result"

  out=$(get_dep_filesystems /a /a/c)
  result="/a/b/c
/a/b"
  [ "$out" = "$result" ]
  detecterror $? "get_dep_filesystems /a /a/c: $out != $result"


  out=$(get_dep_filesystems /d /a/c)
  result=""
  [ "$out" = "$result" ]
  detecterror $? "get_dep_filesystems /d: $out != $result"
fi