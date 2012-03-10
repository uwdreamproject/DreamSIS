require 'mongrel_cluster/recipes'
require 'bundler/capistrano'

set :application, "dreamsis"
set :repository,  "svn+ssh://mharris2@isidore.ued.washington.edu/usr/local/svn/dreamsisrepo/trunk"
set :deploy_to, "/usr/local/apps/#{application}"
set :user, "mharris2"
set :deploy_via, :export
set :runner, "root"
# set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
default_run_options[:pty] = true
role :app, "isidore.ued.washington.edu"
role :web, "isidore.ued.washington.edu"
role :db,  "isidore.ued.washington.edu", :primary => true

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
end