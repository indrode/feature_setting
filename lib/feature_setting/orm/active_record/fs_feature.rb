require 'active_record'

module FeatureSetting
  class FsFeature < ActiveRecord::Base
    FEATURES = {
      test: false
    }.freeze

    def features
      self.class::FEATURES
    end

    def klass
      self.class
    end

    class << self
      def method_missing(_method, *_args)
        false
      end

      def respond_to_missing?(*_args)
        true
      end

      def features
        new.features
      end

      def klass
        new.klass.to_s
      end

      def init_features!(remove_old_features: false)
        features.each do |key, value|
          create_feature(key, value)
          define_checker_method(key)
          define_enabler_method(key)
          define_disabler_method(key)
        end
        remove_old_features! if remove_old_features
      end

      def cache_features!
        features.each do |key, value|
          create_feature(key, value)
          value = find_by(key: key, klass: klass).enabled
          define_checker_method(key) { value }
          define_enabler_method(key) { false }
          define_disabler_method(key) { false }
        end
      end

      def define_checker_method(key, &block)
        unless block_given?
          block = proc do
            find_by(key: key, klass: klass)&.enabled ? true : false
          end
        end
        define_singleton_method("#{key}_enabled?") { block.call }
      end

      def define_enabler_method(key, &block)
        unless block_given?
          block = proc do
            enable!(key)
          end
        end
        define_singleton_method("enable_#{key}!") { block.call }
      end

      def define_disabler_method(key, &block)
        unless block_given?
          block = proc do
            disable!(key)
          end
        end
        define_singleton_method("disable_#{key}!") { block.call }
      end

      def remove_old_features!
        where(key: all_stored_features - defined_features).destroy_all
      end

      def reset_features!
        init_features! if where(klass: klass).delete_all
      end

      def enable!(key)
        return unless features.key?(key.to_sym)

        record = find_by(key: key, klass: klass)
        record.update(enabled: true)
      end

      def disable!(key)
        return unless features.key?(key.to_sym)

        record = find_by(key: key, klass: klass)
        record.update(enabled: false)
      end

      def defined_features
        features.keys.map(&:to_s)
      end

      private

      def all_stored_features
        all.pluck(:key)
      end

      def create_feature(key, value)
        create_with(
          key: key,
          enabled: value,
          klass: klass
        ).find_or_create_by(
          klass: klass,
          key: key
        )
      end
    end
  end

  # alias this class to Feature
  Feature = FsFeature
end
