require 'mongrel_cluster/recipes'
require 'bundler/capistrano'

set :application, "dreamsis"
set :deploy_to, "/usr/local/apps/#{application}"
set :user, "mharris2"
set :runner, "root"
set :use_sudo, true

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.8.7@rails235'        # Or whatever env you want it to run in.

default_run_options[:pty] = true
set :repository, "git@github.com:uwdreamproject/DreamSIS.git"  # Your clone URL
set :scm, "git"

ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache

role :app, "expo.uaa.washington.edu"
role :web, "expo.uaa.washington.edu"
role :db,  "expo.uaa.washington.edu", :primary => true

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  
end

namespace :vpn do
  desc "Connect to the UAA VPN"
  task :connect do
    system "osascript lib/uaavpn.scpt"
  end
  
  desc "Connect to the VPN and then commit to SVN"  
  task :commit do
    vpn.connect
    deploy.commit
  end
  
  desc "Connect to the VPN, commit to SVN and deploy to server"
  task :full_deploy do
    vpn.connect
    deploy.commit
    deploy.update
    deploy.restart
  end
  
end

namespace :deploy do
  desc "Commit the current working directory to svn"
  task :commit do
    print "Enter commit message: "
    commit_msg = STDIN.gets
    system "svn ci -m \"#{commit_msg}\""
  end
    
  desc "[internal] Updates the symlink for database.yml and other files to the just deployed release."
  task :config_symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    run "ln -nfs #{shared_path}/config/exceptional.yml #{release_path}/config/exceptional.yml" 
    run "ln -nfs #{shared_path}/config/google_analytics.yml #{release_path}/config/google_analytics.yml" 
    run "ln -nfs #{shared_path}/config/omniauth_keys.yml #{release_path}/config/omniauth_keys.yml" 
    run "ln -nfs #{shared_path}/config/action_mailer.rb #{release_path}/config/initializers/action_mailer.rb" 
    run "ln -nfs #{shared_path}/config/certs #{release_path}/config/certs" 
  end
  
end

after "deploy:finalize_update", "deploy:config_symlink"