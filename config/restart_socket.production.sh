#!/bin/sh

restart() {
  echo "restarting..."
  echo "stop yong_wa_socket"
  eval "/etc/init.d/yong_wa_socket stop" 
  
  echo "restart resque worker"
  eval "/etc/init.d/resque_worker stop"
  eval "/etc/init.d/resque_worker start"

  echo "start yong_wa_socket"
  eval "/etc/init.d/yong_wa_socket start" 
  echo "restarted"
}

restart