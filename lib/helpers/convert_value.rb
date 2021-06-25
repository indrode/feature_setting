module ConvertValue
  class << self
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    def convert_to_type(value, type)
      case type
      when 'String'
        value.to_s
      when 'TrueClass'
        true
      when 'NilClass', 'FalseClass'
        false
      when 'Fixnum', 'Integer'
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
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

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
