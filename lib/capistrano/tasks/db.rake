namespace :deploy do

  namespace :db do

    desc "db:migrate for deploy server"
    task :migrate, :roles => :db, :only => { :primary => true } do
      run "cd #{current_path} && #{rake} db:migrate"
    end

    desc "db:seed for deploy server"
    task :seed, :roles => :db, :only => { :primary => true } do
      run "cd #{current_path} && #{rake} db:seed "
    end
  end

end