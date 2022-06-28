#!/bin/ash

# echo "... [$0] ..."
# Execute the parameters provided from CLI

if [  -z "$ENTRYPOINT_PARAMS" ] ; then
  echo "---------- TEMP TIL CACHET ----------"
 # Kill the background crond and restart with the forground service.  Crond is the default
 # container process.
 TEST="$(/usr/bin/pgrep crond)"
 if [ $? -eq 0 ] ; then
    # Kill the background cron service
    /usr/bin/sudo /usr/bin/killall crond
 fi
 unset TEST
 echo "---------- [ {DEFAULT}SCHEDULER(crond) ] ----------"
 /usr/bin/sudo /usr/sbin/crond -f -l 0
fi
