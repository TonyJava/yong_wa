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

end