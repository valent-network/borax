# frozen_string_literal: true

require './lib/corona'
require './config/application'

namespace :db do
  desc 'Create Datbase'
  task :create do
    Sequel.connect(Corona.config.database.merge('database' => 'postgres')) do |db|
      db.execute "CREATE DATABASE #{Corona.config.database['database']}"
      Corona.logger.info("Database #{Corona.config.database['database']} created")
    rescue Sequel::DatabaseError => e
      # TODO: dirty fix
      raise e unless /already exists/.match?(e.message)

      Corona.logger.warn("Database #{Corona.config.database['database']} already exists")
    end
  end

  desc 'Run migrations'
  task :migrate, [:version] do |_t, args|
    require 'sequel/core'
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.connect(Corona.config.database) do |db|
      Sequel::Migrator.run(db, 'db/migrations', target: version)
    end
  end

  desc 'Dump Schema'
  task :schema_dump do
    DB.extension :schema_dumper
    File.open('db/schema.rb', 'w') { |f| f.puts(DB.dump_schema_migration(same_db: true)) }
  end
end
