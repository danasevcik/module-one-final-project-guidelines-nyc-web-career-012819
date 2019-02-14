require 'bundler'
require 'dotenv/load'
Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger.level = 1 # comment out to use rake
require_all 'lib'
