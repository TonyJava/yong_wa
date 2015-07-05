
# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'yong_wa'
set :repo_url, 'git@github.com:lzhgamedev/yong_wa.git'

set :deploy_to, "/www/web/#{fetch(:application)}"
set :deploy_user, "root"


# ---------
#  bundler
# ---------
set :rake, "bundle exec rake"



# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
#set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, '2.1.5'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all
#set :rbenv_custom_path, '/root/.rbenv'

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :resque do

  desc "init script"
  task :setup do
    deployments = File.join(File.dirname(__FILE__), "deployments")
    Dir.chdir(deployments) do |path|
      Dir.glob("{resque_worker}") do |file|
        config = ERB.new(File.read(file))
        base_name = File.basename(file)
        put config.result(binding), File.join("tmp", base_name)
        try_sudo "cp /tmp/#{file} /etc/init.d/#{base_name}"
        try_sudo "chmod 755 /etc/init.d/#{base_name}"
      end
    end
  end

  namespace :worker do
    task :start do
      execute "/etc/init.d/resque_worker start"
    end
    task :stop do
      execute "/etc/init.d/resque_worker stop"
    end

  end

end
