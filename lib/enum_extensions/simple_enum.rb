module EnumExtensions

  module SimpleEnum

    def simple_enum(definitions)
      klass = self
      definitions.each do |name, values|
        # statuses = { }
        enum_values = ActiveSupport::HashWithIndifferentAccess.new
        name        = name.to_sym

        # def self.statuses statuses end
        detect_enum_conflict!(name, name.to_s.pluralize, true)
        klass.singleton_class.send(:define_method, name.to_s.pluralize) { enum_values }

        _enum_methods_module.module_eval do
          # def status=(value) self[:status] = statuses[value] end
          klass.send(:detect_enum_conflict!, name, "#{name}=")
          define_method("#{name}=") { |value|
            if enum_values.key?(value) || value.blank?
              self[name] = enum_values[value]
            elsif enum_values.value?(value)
              # Assigning a value directly is not a end-user feature, hence it's not documented.
              # This is used internally to make building objects from the generated scopes work
              # as expected, i.e. +Conversation.archived.build.archived?+ should be true.
              self[name] = value
            else
              fail ArgumentError, "'#{value}' is not a valid #{name}"
            end
          }

          # def status() statuses.key self[:status] end
          klass.send(:detect_enum_conflict!, name, name)
          define_method(name) { enum_values.key self[name] }

          # def status_before_type_cast() statuses.key self[:status] end
          klass.send(:detect_enum_conflict!, name, "#{name}_before_type_cast")
          define_method("#{name}_before_type_cast") { enum_values.key self[name] }

          pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
          pairs.each { |value, i| enum_values[value] = i }
        end
        defined_enums[name.to_s] = enum_values
      end
    end

  end

end
