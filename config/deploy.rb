require 'rvm-capistrano'

set :default_environment, {'PATH' => "/usr/bin:$PATH"}

set :application, "Recruiting on Rails"
set :repository,  "git@github.com:nwsmith/RecruitingOnRails"

set :scm, :git
set :scm_verbose, true
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, "nathan.smith"
set :branch, "master"
set :deploy_via, :remote_cache

role :web, "172.16.81.129"                          # Your HTTP server, Apache/etc
role :app, "172.16.81.129"                          # This may be the same as your `Web` server
role :db,  "172.16.81.129", :primary => true # This is where Rails migrations will run

set :deploy_to, "/var/www/recruiting.solium.com"
default_run_options[:pty] = true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end
