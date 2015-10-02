require 'enum_extensions/simple_enum'
require 'enum_extensions/enum_with_string_values'

module EnumExtensions
end

ActiveRecord::Base.send :extend, EnumExtensions::SimpleEnum, EnumExtensions::EnumWithStringValues
