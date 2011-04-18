#!/bash
echo $$ > testservice.pid
while $(/bin/true); do
  sleep 1
done 
