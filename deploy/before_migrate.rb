on_app_servers do
  run "ln -nfs #{config.shared_path}/config/api-keys.yml #{config.release_path}/config/api-keys.yml"
  run "ln -nfs #{config.shared_path}/config/certs #{config.release_path}/config/certs"
end