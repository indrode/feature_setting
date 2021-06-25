require 'active_record'
require 'json'
require_relative './../../../helpers/convert_value'

module FeatureSetting
  class FsSetting < ActiveRecord::Base
    class SettingKeyNotFoundError < StandardError
      def message
        'Key is missing or does not exist.'
      end
    end

    class SettingTypeMismatchError < StandardError
      def message
        'The value for a setting of type Hash must be a Hash.'
      end
    end

    SETTINGS = {
      test: 'value'
    }.freeze

    def settings
      self.class::SETTINGS
    end

    def klass
      self.class
    end

    class << self
      def settings
        new.settings
      end

      def klass
        new.klass.to_s
      end

      def init_settings!(remove_old_settings: false)
        settings.each do |key, value|
          create_setting(key, value)
          define_getter_method(key)
          define_setter_method(key)
        end
        remove_old_settings! if remove_old_settings
      end

      def cache_settings!
        settings.each do |key, value|
          create_setting(key, value)
          record = find_by key: key, klass: klass
          value = ConvertValue.convert_to_type(record.value, record.value_type)
          define_getter_method(key) { value }
        end
      end

      def define_getter_method(key, &block)
        unless block_given?
          block = proc do
            record = find_by key: key, klass: klass
            ConvertValue.convert_to_type(record.value, record.value_type)
          end
        end

        define_singleton_method(key.to_s) { block.call }
      end

      def define_setter_method(key)
        define_singleton_method("#{key}=") do |value|
          set!(key, value)
        end
      end

      def remove_old_settings!
        where(klass: klass, key: all_stored_keys - defined_keys).delete_all
      end

      def reset_settings!
        init_settings! if where(klass: klass).delete_all
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def set!(key = nil, value = nil)
        raise SettingNotExistsError unless defined_keys.include?(key.to_s)

        record = find_by key: key.to_s, klass: klass
        old_value = ConvertValue.convert_to_type(record.value, record.value_type)

        if record.value_type == 'Hash'
          raise SettingTypeMismatchError unless value.is_a?(Hash)

          new_value = old_value.update(value)
          value_type = 'Hash'
        else
          new_value = value
          value_type = value.class.to_s
        end

        record.update(
          value: ConvertValue.convert_to_string(new_value, new_value.class.to_s),
          value_type: value_type
        )
      end
      alias update! set!
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def existing_key(key = nil, hash = {})
        return unless settings.key?(hash.keys.first) || settings.key?(key.to_sym)

        hash.keys.first || key.to_sym
      rescue StandardError
        nil
      end

      def defined_keys
        settings.keys.map(&:to_s)
      end

      def stored_settings
        hash = {}
        where(klass: klass).each do |record|
          hash[record.key.to_sym] = ConvertValue.convert_to_type(record.value, record.value_type)
        end

        hash
      end

      private

      def all_stored_keys
        all.pluck(:key)
      end

      def create_setting(key, value)
        create_with(
          key: key,
          value: ConvertValue.convert_to_string(value, value.class.to_s),
          value_type: value.class.to_s,
          klass: klass
        ).find_or_create_by(
          klass: klass,
          key: key
        )
      end
    end
  end

  # alias this class to Setting
  Setting = FsSetting
end
