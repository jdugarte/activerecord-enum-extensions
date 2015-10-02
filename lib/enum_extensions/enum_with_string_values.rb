module EnumExtensions

  module EnumWithStringValues

    def enum_s definitions
      definitions.each do |name, values|
        fail ArgumentError unless values.is_a? Array

        values_s = ActiveSupport::OrderedHash.new
        values.each do |value|
          values_s[value.to_sym] = value.to_s
        end

        enum name => values_s
      end
    end

    def simple_enum_s definitions
      definitions.each do |name, values|
        fail ArgumentError unless values.is_a? Array

        values_s = ActiveSupport::OrderedHash.new
        values.each do |value|
          values_s[value.to_sym] = value.to_s
        end
        simple_enum name => values_s
      end
    end

  end

end
