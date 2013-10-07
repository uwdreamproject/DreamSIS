run "echo 'release_path: #{config.release_path}/files' >> #{config.shared_path}/logs.log" 
run "mkdir -p #{config.shared_path}/files"
run "ln -nfs #{config.shared_path}/files #{config.release_path}/files" 
