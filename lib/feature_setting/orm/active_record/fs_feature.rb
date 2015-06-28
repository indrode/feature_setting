require 'active_record'

module FeatureSetting
  class FsFeature < ActiveRecord::Base
    FEATURES = {
      test: false
    }

    class << self
      FEATURES.each do |key, _|
        define_method("#{key}_enabled?") do
          self.find_by_key(key).enabled
        end
      end

      def features
        FEATURES
      end

      def reload_features!
        features.each do |key, value|
          self.create_with(key: key, enabled: value).find_or_create_by(key: key)
        end
        remove_old_features!
      end

      def remove_old_features!
        self.where(key: all_stored_features - defined_features).destroy_all
      end

      def enable!(key)
        if features.has_key?(key.to_sym)
          self.find_by_key(key).update_attributes(enabled: true)
        end
      end

      def disable!(key)
        if features.has_key?(key.to_sym)
          self.find_by_key(key).update_attributes(enabled: false)
        end
      end

      def defined_features
        features.keys.map(&:to_s)
      end

      private

      def all_stored_features
        self.all.pluck(:key)
      end
    end

    # reload_features!
  end
end
