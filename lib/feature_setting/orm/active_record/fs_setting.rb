require 'active_record'

module FeatureSetting
  class FsSetting < ActiveRecord::Base
    self.table_name = 'fs_settings'

    SETTINGS = {
      test: 'value',
    }

    class << self
      SETTINGS.each do |key, _|
        define_method(key.to_s) do
          self.find_by_key(key).value
        end
      end

      def settings
        SETTINGS
      end

      def reload_settings!
        settings.each do |key, value|
          self.create_with(key: key, value: value).find_or_create_by(key: key)
        end
        remove_old_settings!
      end

      def remove_old_settings!
        self.where(key: all_stored_settings - defined_settings).destroy_all
      end

      def set!(key = nil, value = nil, **hash)
        if settings.has_key?(hash.keys.first) || settings.has_key?(key.to_sym)
          self.find_by_key(hash.keys.first || key.to_sym).update_attributes(value: hash.values.first || value)
        end
      end

      def defined_settings
        settings.keys.map(&:to_s)
      end

      private

      def all_stored_settings
        self.all.pluck(:key)
      end
    end

    # reload_settings!
  end
end
