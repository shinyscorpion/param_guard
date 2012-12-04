module ParamGuard

  # Rules describing the requirements for a parameter.
  class ParamDefinition < Struct.new(:presence, :type_or_types, :subdef)
    def required?
      presence == :required
    end

    def types
      Array(type_or_types)
    end

    def types_for_sentence
      a = types.map(&:to_s)
      return nil if a.empty?
      [a[0..-3] + [a.last(2).join(' or ')]].compact.join(', ')
    end
  end

end

