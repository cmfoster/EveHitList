require "rvm/capistrano"
set :rvm_ruby_string, 'default'
set :rvm_type, :user
require "whenever/capistrano"
require "bundler/capistrano"
set :application, "EveHitList"
set :whenever_command, "cd #{current_path} && bundle exec whenever"
set :user, "n0de"
set :repository,  "git@github.com:cmfoster/EveHitList.git"
set :branch, "master"
set :smc_passphrase, "cooler17"

set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :copy
set :use_sudo, false

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "74.207.237.5"                          # Your HTTP server, Apache/etc
role :app, "74.207.237.5"                          # This may be the same as your `Web` server
role :db,  "74.207.237.5", :primary => true # This is where Rails migrations will run
role :db,  "74.207.237.5"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
 task :start do ; end
 task :stop do ; end
 task :restart, :roles => :app, :except => { :no_release => true } do
   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   run "cd #{current_path} && rake queue:restart_workers RAILS_ENV=production"
   run "god start -c #{current_path}/config/monitor-redis-resque.rb"
 end
end

