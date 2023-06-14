#!/bin/bash

# Start the first process
/opt/bin/entrypoint-apache.sh &
  
# Start the second process
/opt/bin/entrypoint-cron.sh &
  
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?