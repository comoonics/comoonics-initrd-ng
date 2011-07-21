if ! runonce; then
  echo -n "Testing lvm_get_vg.."

  result="mobilix-20"
  out=$(lvm_get_vg /dev/mapper/mobilix--20-lv_root64bit)
  test $? -eq 0 && test "$out" = "$result"
  detecterror $? "lvm_get_vg /dev/mapper/mobilix--20-lv_root64bit: $out != $result"

  result="mobilix-20"
  out=$(lvm_get_vg /dev/mobilix-20/lv_root64bit)
  test $? -eq 0 && test "$out" = "$result"
  detecterror $? "lvm_get_vg /dev/mobilix-20/lv_root64bit: $out != $result"

  result=""
  out=$(lvm_get_vg /dev/sda1)
  test $? -ne 0 && test "$out" = "$result"
  detecterror $? "lvm_get_vg /dev/sda: $out != $result"

  echo
  echo -n "Testing lvm_check.."
  
  result=""
  lvm_check_stat_output="fc"
  out=$(lvm_check /dev/mapper/mobilix--20-lv_root64bit)
  test $? -eq 0 && test "$out" = "$result"
  detecterror $? "lvm_check /dev/mapper/mobilix--20-lv_root64bit: $out != $result"

  result=""
  out=$(lvm_check /dev/mobilix-20/lv_root64bit)
  test $? -eq 0 && test "$out" = "$result"
  detecterror $? "lvm_check /dev/mobilix-20/lv_root64bit: $out != $result"

  lvm_check_stat_output="8"
  result=""
  out=$(lvm_check /dev/sda)
  test $? -ne 0
  detecterror $? "lvm_check /dev/sda: $out != $result"

  lvm_check_stat_output=""
  result=""
  out=$(lvm_check /ab)
  test $? -ne 0 && test "$out" = "$result"
  detecterror $? "lvm_check /ab: $out != $result"

  echo
  echo -n "Testing device_mapper_check.."
  
  result=""
  device_mapper_check_stat_output="fc"
  out=$(device_mapper_check /dev/mapper/mobilix--20-lv_root64bit)
  test $? -eq 0 && test "$out" = "$result"
  detecterror $? "device_mapper_check /dev/mapper/mobilix--20-lv_root64bit: $out != $result"

  result=""
  out=$(device_mapper_check /dev/mobilix-20/lv_root64bit)
  test $? -eq 0 && test "$out" = "$result"
  detecterror $? "device_mapper_check /dev/mobilix-20/lv_root64bit: $out != $result"

  device_mapper_check_stat_output="8"
  result=""
  out=$(device_mapper_check /dev/sda1)
  test $? -ne 0 && test "$out" = "$result"
  detecterror $? "device_mapper_check /dev/sda: $out != $result"

  device_mapper_check_stat_output=""
  result=""
  out=$(device_mapper_check /ab)
  test $? -ne 0 && test "$out" = "$result"
  detecterror $? "device_mapper_check /ab: $out != $result"

  echo
  echo -n "Testing device_mapper_multipath_check.."
  
  device_mapper_multipath_check_multipath_return=0
  device_mapper_check_stat_output="fc"
  result=""
  out=$(device_mapper_multipath_check /dev/mapper/mpath1)
  test $? -eq 0
  detecterror $? "device_mapper_multipath_check /dev/mapper/mpath1"

  result=""
  device_mapper_check_stat_output="fc"
  device_mapper_multipath_check_multipath_return=1
  out=$(device_mapper_multipath_check /dev/mapper/mobilix--20-lv_root64bit)
  test $? -ne 0
  detecterror $? "device_mapper_multipath_check /dev/mapper/mobilix--20-lv_root64bit"

  result=""
  out=$(device_mapper_multipath_check /dev/mobilix-20/lv_root64bit)
  test $? -ne 0
  detecterror $? "device_mapper_multipath_check /dev/mobilix-20/lv_root64bit"

  device_mapper_check_stat_output="8"
  result=""
  out=$(device_mapper_multipath_check /dev/sda1)
  test $? -ne 0
  detecterror $? "device_mapper_multipath_check /dev/sda"

  device_mapper_check_stat_output=""
  result=""
  out=$(device_mapper_multipath_check /ab)
  test $? -ne 0
  detecterror $? "device_mapper_multipath_check /ab"

  echo
fi