require 'simplecov'
SimpleCov.start
require 'bundler/setup'
#require 'codeclimate-test-reporter'
#CodeClimate::TestReporter.start
Bundler.setup
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'feature_setting'
require 'hashie'
require 'generators/feature_setting/install/templates/migrations/create_fs_tables.rb'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = :warn
CreateFsTables.up
