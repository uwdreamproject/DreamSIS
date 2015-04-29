cluster_name = config.current_role
server_id = config.current_name

run "echo '#{cluster_name}:#{server_id}' > #{config.release_path}/config/server_id.txt"