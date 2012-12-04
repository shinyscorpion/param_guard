module ParamGuard
  InvalidParameters = Class.new(StandardError)
  ParameterMissing = Class.new(InvalidParameters)
  ParameterOfInvalidType = Class.new(InvalidParameters)

  autoload :ParamDefinition, 'param_guard/param_definition'

  class << self

    # Sanitiize params based on rules in defs.
    # Returns a duplicate of params, from which all non-declared fields are deleted.
    # Raises errors ParameterMissing or ParameterOfInvalidType.
    def filter(params, defs, parent_keys = [])
      return params if defs.nil?
      keys_to_keep = []
      defs.each do |key, key_def|
        definition = ParamDefinition.new(*key_def)
        structure, value, params_to_keep = get_param(params, key)
        if value
          if definition.types.any?
            unless definition.types.any?{|t| is_of_type?(t, value, structure)}
              raise ParameterOfInvalidType.new(
                "param '#{keys_to_s(parent_keys + [key])}' must be #{definition.types_for_sentence}"
              )
            end
          end
          keys_to_keep.concat params_to_keep.keys.map(&:to_s)
          if structure == :normal && value.kind_of?(Hash)
            params[key] = filter(value, definition.subdef, parent_keys + [key])
          end
        elsif definition.required?
          raise ParameterMissing.new(
            "param '#{keys_to_s(parent_keys + [key])}' is missing"
          )
        end
      end
      filtered = params.dup
      filtered.delete_if{|key, value| ! keys_to_keep.include? key.to_s }
      filtered
    end

    private

    def get_param(params, key)
      key, value = if v = params[key.to_sym]
                     [key.to_sym, v]
                   elsif v = params[key.to_s]
                     [key.to_s, v]
                   else
                     [key, nil]
                   end
      if value
        return :normal, value, { key => value }
      elsif (keys = params.keys.grep(/\A#{Regexp.escape(key.to_s)}\(\d+[if]?\)\z/)).any?
        values = keys.sort.map{|k| params[k]}
        return :multi, values, Hash[keys.map{|k| [k, params[k]]}]
      else
        return :none, nil, {}
      end
    end

    def is_of_type?(type, value, structure)
      case type.to_sym
      when :string
        value.kind_of? String
      when :integer
        value.kind_of? Fixnum
      when :float
        value.kind_of? Float
      when :hash
        value.kind_of? Hash
      when :scalar
        [String, Fixnum, Float, NilClass, FalseClass, TrueClass].any?{|klass| value.kind_of? klass}
      when :array
        value.kind_of? Array
      when :multi
        structure == :multi
      else
        raise "Unknown type: #{type.inspect}"
      end
    end

    def keys_to_s(keys)
      "#{keys.first}#{keys[1..-1].map{|k| "[#{k}]"}.join}"
    end

  end
end


