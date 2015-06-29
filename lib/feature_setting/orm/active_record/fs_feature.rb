require 'active_record'

module FeatureSetting
  class FsFeature < ActiveRecord::Base
    FEATURES = {
      test: false
    }

    def features
      self.class::FEATURES
    end

    def klass
      self.class
    end

    class << self
      def features
        self.new.features
      end

      def klass
        self.new.klass
      end

      def init_features!
        features.each do |key, value|
          self.create_with(key: key, enabled: value, klass: klass).find_or_create_by(klass: klass, key: key)
          define_singleton_method("#{key}_enabled?") do
            record = self.where(key: key, klass: klass).first
            record.enabled
          end
          define_singleton_method("enable_#{key}!") do
            enable!(key)
          end
          define_singleton_method("disable_#{key}!") do
            disable!(key)
          end
        end
        remove_old_features!
      end

      def remove_old_features!
        self.where(key: all_stored_features - defined_features).destroy_all
      end

      def reset_features!
        self.where(klass: klass).destroy_all
        init_features!
      end

      def enable!(key)
        if features.has_key?(key.to_sym)
          record = self.where(key: key, klass: klass).first
          record.update_attributes(enabled: true)
        end
      end

      def disable!(key)
        if features.has_key?(key.to_sym)
          record = self.where(key: key, klass: klass).first
          record.update_attributes(enabled: false)
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
