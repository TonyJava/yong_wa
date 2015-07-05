#!/bin/sh

start() {
  cd <%= current_path %>
  RAILS_ENV=production bundle exec rails runner script/resque_worker start
}

stop() {
  cd <%= current_path %>
  RAILS_ENV=production bundle exec rails runner script/resque_worker stop
}

status() {
  cd <%= current_path %>
  RAILS_ENV=production bundle exec rails runner script/resque_worker status
}

restart() {
  cd <%= current_path %>
  RAILS_ENV=production bundle exec rails runner script/resque_worker restart
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
  restart)
    restart
    ;;
  *)
    echo "Usages: resque_worker {start|stop|restart|status}"
    ;;
esac