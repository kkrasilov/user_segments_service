require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

# Basic settings
set :application_name, 'user_segments_service'
set :domain, 'your-server.com'
set :deploy_to, '/var/www/user_segments_service'
set :repository, 'git@github.com:your-username/user_segments_service.git'
set :branch, 'main'

# Optional settings
set :user, 'deploy'
set :port, '22'

# Shared files and directories
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp')
set :shared_files, fetch(:shared_files, []).push('.env')

# rbenv settings
set :rbenv_path, '$HOME/.rbenv'

# Environment
task :remote_environment do
  invoke :'rbenv:load'
end

# Setup task
task :setup do
  command %[mkdir -p "#{fetch(:shared_path)}/log"]
  command %[mkdir -p "#{fetch(:shared_path)}/tmp"]
  command %[mkdir -p "#{fetch(:shared_path)}/config"]
  
  comment "Creating .env file"
  command %[touch "#{fetch(:shared_path)}/.env"]
  
  comment "Be sure to edit '#{fetch(:shared_path)}/.env' and add environment variables"
end

# Deployment task
desc "Deploys the current version to the server"
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        
        comment "Restarting application"
        command %{sudo systemctl restart #{fetch(:application_name)}}
      end
    end
  end
end

# Database tasks
namespace :db do
  desc "Run database migrations"
  task :migrate do
    command %{cd #{fetch(:current_path)} && RACK_ENV=production bundle exec rake db:migrate}
  end
  
  desc "Load seed data"
  task :seed do
    command %{cd #{fetch(:current_path)} && RACK_ENV=production bundle exec rake db:seed}
  end
  
  desc "Setup database"
  task :setup do
    command %{cd #{fetch(:current_path)} && RACK_ENV=production bundle exec rake db:setup}
  end
end
