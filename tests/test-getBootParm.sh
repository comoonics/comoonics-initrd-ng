runonce
if [ $? -ne 0 ]; then
  cmdline1="ro root=/dev/marc/marc com-debug others"
  cmdline=$cmdline1
  echo -n "getBootParm ro"
  result=$(getBootParm ro 2>&1)
  detecterror $? "getBootParm ro returned an error: $result" || echo "FAILED"
  echo "=$result"

  echo -n "getBootParm rot"
  result=$(getBootParm rot 2>&1)
  invdetecterror $? "getBootParm rot did not return an error: $result" || echo "FAILED"
  echo "=$result"
  
  echo -n "getBootParm root"
  result=$(getBootParm root 2>&1)
  expected="/dev/marc/marc"
  test "$result" = "$expected"
  detecterror $? "getBootParm root returned \"$result\" != \"$expected\"" || echo "FAILED"
  echo "=$result"

  echo -n "getBootParm roo root"
  result=$(getBootParm roo "root" 2>&1)
  expected="root"
  test "$result" = "$expected"
  detecterror $? "getBootParm roo root returned \"$result\" != \"$expected\"" || echo "FAILED"
  echo "=$result"
fi