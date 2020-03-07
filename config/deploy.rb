# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

set :application, 'comcon'
set :repo_url, 'git@github.com:kortirso/comcon.git'

set :deploy_to, '/var/www/html/comcon'
set :deploy_user, 'deploy'

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('public/assets/mailer.css', 'config/secrets.yml', 'config/database.yml', 'config/application.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'storage')

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
end

namespace :yarn do
  desc 'Yarn'
  task :install do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec yarn install'
        end
      end
    end
  end
end

namespace :sphinx do
  desc 'Rebuild sphinx'
  task :rebuild do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'ts:rebuild'
        end
      end
    end
  end

  desc 'Configure sphinx'
  task :configure do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'ts:configure'
        end
      end
    end
  end
end

after 'bundler:install', 'yarn:install'
after 'deploy:published', 'bundler:clean'
after 'deploy:restart', 'sphinx:configure'
after 'sphinx:configure', 'sphinx:rebuild'
