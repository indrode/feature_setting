require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'


module FeatureSettings
  module Generators

    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration

      # def self.next_migration_number(path)
      #   ActiveRecord::Generators::Base.next_migration_number(path)
      # end

      desc 'Generates database tables for feature_settings'
      source_root File.expand_path('../templates', __FILE__)

      def create_migrations
        migration_name = 'create_feature_setting_tables.rb'
        migration_template "migrations/#{migration_name}", "db/migrate/#{migration_name}"
      end
    end
  end
end
