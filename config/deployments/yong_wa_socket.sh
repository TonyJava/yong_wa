#!/bin/sh
set -u
set -e

current_path=/www/web/yong_wa/current

start() {
  cd $current_path
  echo "deque all workers in queue"
  bundle exec rails runner "Resque.dequeue(ResqueSocket)"
  echo "enque a worker"
  bundle exec rails runner "Resque.enqueue(ResqueSocket)"
  if [[ $? -eq 0 ]]; then
    echo "OK"
  fi
}

stop() {
  pid=`lsof -i tcp:2626 -t`
  ps $pid > /dev/null
  if [[ $? -eq 0 ]]; then
    if [[ -n $pid ]]; then
      kill -9 $pid
      echo "yong_wa_socket:2626 stopped"
    else
      echo "yong_wa_socket:2626 not exist"
    fi
  else
    echo "NG"
  fi
}

status() {
  pid=`lsof -i tcp:2626 -t`
  if [[ -n $pid ]]; then
    echo "2626 is already running"
  else
    echo "2626 is open"
  fi
}

case $1 in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  *)
    echo "Usages: yong_wa_socket |start|stop|status|"
    ;;
esac