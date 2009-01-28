runonce
if [ $? -eq 0 ]; then
  cmdline1="ro root=/dev/marc/marc com-debug others"
  cmdline=$cmdline1
  getBootParm ro && echo found && 
  (getBootParm rot || true) &&
  getBootParm root && echo found &&
  getBootParm roo "root" && echo " found" &&
  getBootParm ro && echo " found"
fi