#!/bin/sh

restart() {
  echo "restarting..."
  echo "stop yong_wa_socket"
  eval "./config/deployments/yong_wa_socket.sh stop"  
  
  echo "restart resque worker"
  bundle exec rails runner script/resque_worker stop
  bundle exec rails runner script/resque_worker start

  echo "start yong_wa_socket"
  bundle exec rails runner "Resque.enqueue(ResqueSocket)"
  echo "restarted"
}

restart
