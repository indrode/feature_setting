require 'bundler/setup'
Bundler.setup
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'byebug'
require 'feature_setting'
require 'generators/feature_setting/install/templates/migrations/create_fs_tables.rb'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'file::memory:?cache=shared'
)
ActiveRecord::Base.logger = Logger.new(STDOUT)
CreateFsTables.up
