run "echo 'release_path: #{release_path}/files' >> #{shared_path}/logs.log" 
run "mkdir -p #{shared_path}/files"
run "ln -nfs #{shared_path}/files #{release_path}/files" 
