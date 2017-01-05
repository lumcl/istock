# Change to match your CPU core count
#workers 1

# Min and Max threads per worker
#threads 1, 6

app_dir = File.expand_path("../..", __FILE__)
tmp_dir = "#{app_dir}/tmp"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
port        ENV['PORT']     || 3018
environment rails_env
#daemonize true

# Set up socket location
#bind "unix://#{tmp_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{tmp_dir}/log/puma.stdout.log", "#{tmp_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{tmp_dir}/pids/puma.pid"
state_path "#{tmp_dir}/pids/puma.state"
#activate_control_app

on_restart do
  puts 'On restart...'
  ActiveRecord::Base.connection_pool.disconnect!
  Sapdb.connection_pool.disconnect!
  # require "active_record"
  # ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  # ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end

on_worker_boot do
  puts 'On Startup'
  require "active_record"
  ActiveRecord::Base.connection_pool.disconnect!
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
