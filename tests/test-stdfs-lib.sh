if ! runonce; then
  MOUNTSFILE=$(tempfile)
  cat > $MOUNTSFILE <<EOF
/dev1 /a fstype1 rest
/dev2 /a/b fstype2 rest
/dev3 /a/b/c fstype3 rest
/dev4 /a/c fstype4 rest
/dev5 /b fstype5 rest
/dev6 /b/a fstype6 rest
EOF
  
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
  
  echo -n "Testing get_dep_filesystems $MOUNTSFILE"
  out=$(get_dep_filesystems /a)
  result="/a/c
/a/b/c
/a/b"
  test "$out" = "$result"
  detecterror $? "get_dep_filesystems /a: $out != $result"

  out=$(get_dep_filesystems /a /a/b)
  result="/a/c"
  test "$out" = "$result"
  detecterror $? "get_dep_filesystems /a /a/b: $out != $result"

  out=$(get_dep_filesystems /a /a/c)
  result="/a/b/c
/a/b"
  test "$out" = "$result"
  detecterror $? "get_dep_filesystems /a /a/c: $out != $result"

  out=$(get_dep_filesystems /d /a/c)
  result=""
  test "$out" = "$result"
  detecterror $? "get_dep_filesystems /d: $out != $result"
  echo
  
  echo -n "Testing get_filesystem $MOUNTSFILE"

  result="/dev1 /a fstype1 rest"
  out=$(get_filesystem /a)
  test $? -eq 0 && test "$out" = "$result"
  detecterror $? "get_filesystem /a: $out != $result"

  result="/dev2 /a/b fstype2 rest"
  out=$(get_filesystem /a/b)
  test $? -eq 0 && test "$out" = "$result"
  detecterror $? "get_filesystem /a/b: $out != $result"

  result=""
  out=$(get_filesystem /c)
  test $? -ne 0 && test "$out" = "$result"
  detecterror $? "get_filesystem /c: $out != $result"
 
  result=""
  out=$(get_filesystem)
  test $? -ne 0 && test "$out" = "$result"
  detecterror $? "get_filesystem: $out != $result"
  echo 

  rm -f $MOUNTSFILE
fi