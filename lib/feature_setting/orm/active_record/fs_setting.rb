require 'active_record'
require 'json'

module FeatureSetting
  class FsSetting < ActiveRecord::Base
    SETTINGS = {
      test: 'value',
    }

    def settings
      self.class::SETTINGS
    end

    def klass
      self.class
    end

    class << self
      def settings
        self.new.settings
      end

      def klass
        self.new.klass.to_s
      end

      def init_settings!(remove_old_settings = false)
        settings.each do |key, value|
          self.create_with(key: key, value: convert_to_string(value, value.class.to_s), value_type: value.class.to_s, klass: klass).find_or_create_by(klass: klass, key: key)
          define_getter_method(key)
          define_setter_method(key)
        end
        remove_old_settings! if remove_old_settings
      end

      def cache_settings!
        settings.each do |key, value|
          self.create_with(key: key, value: convert_to_string(value, value.class.to_s), value_type: value.class.to_s, klass: klass).find_or_create_by(klass: klass, key: key)
          record = self.where(key: key, klass: klass).first
          value = convert_to_type(record.value, record.value_type)
          define_getter_method(key) { value }
        end
      end

      def define_getter_method(key, &block)
        block = Proc.new do
          record = self.where(key: key, klass: klass).first
          convert_to_type(record.value, record.value_type)
        end unless block_given?

        define_singleton_method(key.to_s) { block.call }
      end

      def define_setter_method(key)
        define_singleton_method("#{key}=") do |value|
          set!(key, value)
        end
      end

      def remove_old_settings!
        self.where(klass: klass, key: all_stored_keys - defined_keys).destroy_all
      end

      def reset_settings!
        self.where(klass: klass).destroy_all
        init_settings!
      end

      def set!(key = nil, value = nil)
        fail 'ERROR: FsSetting key is missing or does not exist.' unless defined_keys.include?(key.to_s)
        record = self.where(key: key.to_s, klass: klass).first
        old_value = convert_to_type(record.value, record.value_type)

        if record.value_type == 'Hash'
          fail 'ERROR: The value for a setting of type Hash must be a Hash.' unless value.is_a?(Hash)
          new_value = old_value.update(value)
          value_type = 'Hash'
        else
          new_value = value
          value_type = value.class.to_s
        end

        record.update_attributes(
          value: convert_to_string(new_value, new_value.class.to_s),
          value_type: value_type
        )
      end

      def existing_key(key = nil, hash = {})
        settings.key?(hash.keys.first) || settings.key?(key.to_sym)
        hash.keys.first || key.to_sym
      rescue
        nil
      end

      def defined_keys
        settings.keys.map(&:to_s)
      end

      def stored_settings
        hash = {}
        self.where(klass: klass).each do |record|
          hash[record.key.to_sym] = convert_to_type(record.value, record.value_type)
        end

        hash
      end

      private

      def all_stored_keys
        self.all.pluck(:key)
      end

      def convert_to_type(value, type)
        case type
        when 'String'
          value.to_s
        when 'TrueClass'
          true
        when 'NilClass'
          false
        when 'FalseClass'
          false
        when 'Fixnum'
          value.to_i
        when 'Integer'
          value.to_i
        when 'Float'
          value.to_f
        when 'Symbol'
          value.to_sym
        when 'Array'
          value.split('|||')
        when 'Hash'
          Hashie::Mash.new(JSON.parse(value))
        end
      end

      def convert_to_string(value, type)
        case type
        when 'Hash', 'Hashie::Mash'
          value.to_json
        when 'Array'
          value.join('|||')
        else
          value.to_s
        end
      end
    end
  end

  # alias this class to Setting
  Setting = FsSetting
end
