# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'archivesspace_web_checker'
set :repo_url, 'git@github.com:harvard-library/archivesspace-checker.git'

set :bundle_bins, fetch(:bundle_bins, []).push('nohup')

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp', 'tmp', 'tmp', 'vendor/bundle', 'public')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

namespace :deploy do
  task :restart do
    on roles(:app) do
      execute :touch, "#{release_path}/tmp/restart.txt"
    end
  end

  task :start do
    on roles(:app) do
      execute :touch, "#{release_path}/tmp/restart.txt"
    end
  end

  task :stop do
    # Nothing
  end

  task :assets do
    on roles(:app) do
      within current_path do
        execute :rake, 'assets:precompile'
      end
    end
  end

  before 'deploy:start', 'rvm:hook'
  before 'deploy:stop', 'rvm:hook'
  before 'deploy:assets', 'rvm:hook'
  before 'deploy:finished', 'deploy:assets'
  after  'deploy:finished', 'deploy:restart'

  before 'bundler:install', 'rvm:hook'


end
