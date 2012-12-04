$: << File.expand_path("../../lib", __FILE__)
require 'test/unit'
require 'param_guard/param_definition'

class ParamGuardParamDefinitionTest < Test::Unit::TestCase
  def test_types_for_sentence_no_types
    assert_equal nil, ParamGuard::ParamDefinition.new.types_for_sentence
  end

  def test_types_for_sentence_one_type
    assert_equal 'string', ParamGuard::ParamDefinition.new(nil, :string).types_for_sentence
  end

  def test_types_for_sentence_two_types
    assert_equal 'string or integer', ParamGuard::ParamDefinition.new(nil, [:string, :integer]).types_for_sentence
  end

  def test_types_for_sentence_three_types
    assert_equal 'hash, string or integer', ParamGuard::ParamDefinition.new(nil, [:hash, :string, :integer]).types_for_sentence
  end
end
