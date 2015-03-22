# namespace :deploy do

  namespace :db do

    desc "db:create for deploy server"
    task :create do
      on roles(:db) do
        within "#{current_path}" do
          with only: {primary: true}, rails_env: :production do
            execute :rake, "db:create"
          end
        end
      end
    end

    desc "db:migrate for deploy server"
    task :migrate do
      on roles(:db) do
        within "#{current_path}" do
          with only: {primary: true}, rails_env: :production do
            execute :rake, "db:migrate"
          end
        end
      end
    end

    desc "db:seed for deploy server"
    task :seed do
      on roles(:db) do
        within "#{current_path}" do
          with only: {primary: true}, rails_env: :production do
            execute :rake, "db:seed"
          end
        end
      end
    end

  end

# end