require 'active_record'
require 'yaml'

env = ENV['RACK_ENV'] || 'development'

# Use DATABASE_URL if available, otherwise use config
if ENV['DATABASE_URL']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  database_config = {
    'development' => {
      'adapter' => 'postgresql',
      'database' => 'user_segments_dev',
      'host' => 'localhost',
      'encoding' => 'utf8'
    },
    'production' => {
      'adapter' => 'postgresql',
      'database' => 'user_segments_prod',
      'host' => 'localhost',
      'encoding' => 'utf8',
      'username' => ENV['DB_USERNAME'],
      'password' => ENV['DB_PASSWORD']
    }
  }
  
  ActiveRecord::Base.establish_connection(database_config[env])
end

ActiveRecord::Base.logger = Logger.new(STDOUT) if env == 'development'
