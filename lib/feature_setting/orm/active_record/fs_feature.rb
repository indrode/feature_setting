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
      def method_missing(m, *args)
        false
      end

      def respond_to_missing?(*args)
        true
      end

      def features
        self.new.features
      end

      def klass
        self.new.klass.to_s
      end

      def init_features!(remove_old_features = false)
        features.each do |key, value|
          self.create_with(key: key, enabled: value, klass: klass).find_or_create_by(klass: klass, key: key)
          define_checker_method(key)
          define_enabler_method(key)
          define_disabler_method(key)
        end
        remove_old_features! if remove_old_features
      end

      def cache_features!
        features.each do |key, value|
          self.create_with(key: key, enabled: value, klass: klass).find_or_create_by(klass: klass, key: key)
          value = self.where(key: key, klass: klass).first.enabled
          define_checker_method(key) { value }
          define_enabler_method(key) { false }
          define_disabler_method(key) { false }
        end
      end

      def define_checker_method(key, &block)
        block = Proc.new do
          record = self.where(key: key, klass: klass).first
          record ? record.enabled : false
        end unless block_given?
        define_singleton_method("#{key}_enabled?") { block.call }
      end

      def define_enabler_method(key, &block)
        block = Proc.new do
          enable!(key)
        end unless block_given?
        define_singleton_method("enable_#{key}!") { block.call }
      end

      def define_disabler_method(key, &block)
        block = Proc.new do
          disable!(key)
        end unless block_given?
        define_singleton_method("disable_#{key}!") { block.call }
      end

      def remove_old_features!
        self.where(key: all_stored_features - defined_features).destroy_all
      end

      def reset_features!
        self.where(klass: klass).destroy_all
        init_features!
      end

      def enable!(key)
        if features.key?(key.to_sym)
          record = self.where(key: key, klass: klass).first
          record.update(enabled: true)
        end
      end

      def disable!(key)
        if features.key?(key.to_sym)
          record = self.where(key: key, klass: klass).first
          record.update(enabled: false)
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

  # alias this class to Feature
  Feature = FsFeature
end
