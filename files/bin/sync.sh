#!/bin/bash
# Start wminput in the background and send its output to file descriptor 3
RET=0
exec 3< <(redis-cli sync 2>&1)
PID=$!
# Read the output of wminput line by line until one line contains Ready
while read line; do
   case "$line" in
   *failed*)
      kill $PID
      RET=1
      break
      ;;
   *SYNC\ done.*)
      kill $PID
      break
      ;;
   *)
      ;;
   esac
done <&3
# Close the file descriptor
exec 3<&-

exit $RET
