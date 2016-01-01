namespace :setup do

  desc "Upload database.yml file."
  task :upload_yml do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
    end
  end

  desc "Seed the database."
  task :seed_db do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "db:migrate"
          execute :rake, "db:seed"
        end
      end
    end
  end

  desc "sidekiq"
    task sidekiq_on: :environment do
      on roles(:app), in: :sequence do
        within "#{current_path}" do
          #execute :bundle_sidekiq
          execute "rerun --background --dir app,db,lib --pattern '{**/*.rb}' --sidekiq --verbose"
        end
      end
  end

  task :upload_nginx do
    on roles(:app) do
      upload! StringIO.new(File.read("config/nginx.conf")), "#{current_path}/config/nginx.conf"
    end
  end

  task :upload_gen_production_key do
    on roles(:db) do
      upload! StringIO.new(File.read("config/gen_production_key.sh")), "#{current_path}/config/gen_production_key.sh"
      execute "chmod +x #{current_path}/config/gen_production_key.sh"
    end
  end

  desc "Symlinks config files for Nginx and Unicorn."
  task :symlink_config do
    on roles(:app) do
      execute "rm -f /etc/nginx/sites-enabled/default"

      execute "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
      execute "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{fetch(:application)}"
      execute "ln -nfs #{current_path}/config/redis_init.sh /etc/init.d/redis_#{fetch(:application)}"
   end
  end

  desc "copy unicorn_init.sh and nginx.conf"
  task :upload_nginx_sh do
    on roles(:app) do
      execute "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/conf.d/#{fetch(:application)}"
      execute "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{fetch(:application)}"
   end
  end


  desc "init script"
  task :resque_setup do
    on roles(:app) do
      #deployments = File.join(File.dirname(__FILE__), "deployments")
      deployments = File.join("#{current_path}", "config")
      #Dir.chdir(deployments) do |path|
      within "#{deployments}" do
        Dir.glob("{resque_worker}") do |file|
          config = ERB.new(File.read(file))
          base_name = File.basename(file)
          put config.result(binding), File.join("tmp", base_name)
          try_sudo "cp /tmp/#{file} /etc/init.d/#{base_name}"
          try_sudo "chmod 755 /etc/init.d/#{base_name}"
        end
      end
    end
  end

  namespace :worker do
    task :start do
      execute "./etc/init.d/resque_worker start"
    end
    task :stop do
      execute "./etc/init.d/resque_worker stop"
    end

  end

end
