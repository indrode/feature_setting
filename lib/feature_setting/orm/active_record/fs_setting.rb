require 'active_record'

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
        self.new.klass
      end

      def init_settings!
        settings.each do |key, value|
          self.create_with(key: key, value: convert_to_string(value, value.class.to_s), value_type: value.class.to_s, klass: klass).find_or_create_by(klass: klass, key: key)
          define_getter_method(key)
          define_setter_method(key)
        end
        remove_old_settings!
      end

      def define_getter_method(key)
        define_singleton_method(key.to_s) do
          record = self.where(key: key, klass: klass).first
          convert_to_type(record.value, record.value_type)
        end
      end

      def define_setter_method(key)
        define_singleton_method("#{key}=") do |value|
          record = self.where(key: key, klass: klass).first
          set!(key, value)
        end
      end

      def remove_old_settings!
        self.where(klass: klass, key: all_stored_settings - defined_settings).destroy_all
      end

      def reset_settings!
        self.where(klass: klass).destroy_all
        init_settings!
      end

      def set!(key = nil, value = nil, **hash)
        key = existing_key(key, hash)
        fail 'ERROR: FsSetting key is missing or does not exist.' unless key

        record = self.where(key: key, klass: klass).first
        new_value = hash.values.first || value
        record.update_attributes(
          value: convert_to_string(new_value, new_value.class.to_s),
          value_type: new_value.class.to_s
        )
      end

      def existing_key(key = nil, hash = {})
        settings.key?(hash.keys.first) || settings.key?(key.to_sym)
        hash.keys.first || key.to_sym
      rescue
        nil
      end

      def defined_settings
        settings.keys.map(&:to_s)
      end

      private

      def all_stored_settings
        self.all.pluck(:key)
      end

      def convert_to_type(value, type)
        case type
        when 'String'
          value.to_s
        when 'Fixnum'
          value.to_i
        when 'Float'
          value.to_f
        when 'Array'
          value.split('|||')
        end
      end

      def convert_to_string(value, type)
        case type
        when 'Array'
          value.join('|||')
        else
          value.to_s
        end
      end
    end
  end
end
