require 'active_record'

module FeatureSetting
  class FsFeature < ActiveRecord::Base
    FEATURES = {
      test: false
    }

    def features
      self.class::FEATURES
    end

    class << self
      def features
        self.new.features
      end

      def init_features!
        features.each do |key, value|
          self.create_with(key: key, enabled: value).find_or_create_by(key: key)
          define_singleton_method("#{key}_enabled?") do
            self.find_by_key(key).enabled
          end
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
  end
end
