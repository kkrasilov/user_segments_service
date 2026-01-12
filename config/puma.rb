# Puma configuration file

# Specify the environment
environment ENV.fetch('RACK_ENV', 'development')

# Number of worker processes
workers ENV.fetch('WEB_CONCURRENCY', 2).to_i

# Number of threads per worker
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
threads threads_count, threads_count

# Port to bind to
port ENV.fetch('PORT', 9292).to_i

# Pidfile location
pidfile ENV.fetch('PIDFILE', 'tmp/pids/puma.pid')

# State file location
state_path ENV.fetch('STATE_FILE', 'tmp/pids/puma.state')

# Logging
stdout_redirect(
  ENV.fetch('STDOUT_LOG', 'log/puma.stdout.log'),
  ENV.fetch('STDERR_LOG', 'log/puma.stderr.log'),
  true
)

# Preload the application before forking workers
preload_app!

# Code to run before forking workers
on_worker_boot do
  # Worker specific setup
  require_relative '../config/database'
end
