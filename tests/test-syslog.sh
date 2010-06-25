if ! runonce; then
  tempfile=$(tempfile)
  path=$(dirname $0)

  echo_local_debug "Tempfile $tempfile"

  for syslogtype in syslogd rsyslogd syslog-ng; do
    echo -n "Testing $syslogtype"
    $(echo ${syslogtype} | tr '-' '_')_config /dev/zero 'kern.*:myserver' '*.*:/dev/console' > $tempfile
    out=$(diff ${path}/test/test-${syslogtype}.out $tempfile)
    detecterror $? "${syslogtype} conf generation failed. Diff: $out" || echo -n " Failed"
    echo
  done
  
  syslogtype=$(detect_syslog)
  detecterror $? "Could not detect syslog type. Don't you have syslog installed!"
  
  [ -n "$syslogtype" ] || return 1
  
  syslogconf=$(default_syslogconf $syslogtype)
  detecterror $? "Could not find default syslog.conf for syslogtype $syslogtype"
  
  repository_store_value doexec 0
  out=$(${syslogtype}_start)
  detecterror $? "Could not start syslog $syslogtype. Output: $out"
  repository_store_value doexec 1
  rm -f $tempfile 
fi