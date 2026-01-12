require 'active_record'

namespace :db do
  desc "Create database"
  task :create do
    env = ENV['RACK_ENV'] || 'development'
    db_name = env == 'production' ? 'user_segments_prod' : 'user_segments_dev'
    
    system("createdb #{db_name}")
    puts "Database #{db_name} created"
  end

  desc "Drop database"
  task :drop do
    env = ENV['RACK_ENV'] || 'development'
    db_name = env == 'production' ? 'user_segments_prod' : 'user_segments_dev'
    
    system("dropdb #{db_name}")
    puts "Database #{db_name} dropped"
  end

  desc "Run database migrations"
  task :migrate do
    require_relative 'config/database'
    
    ActiveRecord::Tasks::DatabaseTasks.migrate
    puts "Migrations completed"
  rescue NoMethodError
    # Fallback for older ActiveRecord API
    ActiveRecord::MigrationContext.new('db/migrate', ActiveRecord::SchemaMigration).migrate
    puts "Migrations completed"
  end

  desc "Rollback database migration"
  task :rollback do
    require_relative 'config/database'
    
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    begin
      ActiveRecord::Tasks::DatabaseTasks.migrate_down(step)
    rescue NoMethodError
      ActiveRecord::MigrationContext.new('db/migrate', ActiveRecord::SchemaMigration).rollback(step)
    end
    
    puts "Rolled back #{step} migration(s)"
  end

  desc "Reset database"
  task :reset => [:drop, :create, :migrate]

  desc "Load seed data"
  task :seed do
    require_relative 'config/database'
    require_relative 'models/user'
    require_relative 'models/segment'
    require_relative 'models/user_segment'
    require_relative 'db/seeds'
    puts "Seed data loaded"
  end

  desc "Setup database (create + migrate + seed)"
  task :setup => [:create, :migrate, :seed]
end
