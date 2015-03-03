root = "/www/web/yong_wa/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

#listen "/tmp/unicorn.yong_wa.sock"
listen 3000
worker_processes 2
timeout 30