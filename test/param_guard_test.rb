$: << File.expand_path("../../lib", __FILE__)
require 'test/unit'
require 'param_guard'

class ParamGuardTest < Test::Unit::TestCase

  def test_filter_returns_only_required_and_permitted_params
    defs = { :a => [:required], :b => [:permitted] }
    params = { :a => 1, :b => 2, :c => 3 }
    filtered = ParamGuard.filter(params, defs)
    assert_equal({ :a => 1, :b => 2 }, filtered)
  end

  def test_filter_raises_error_if_required_param_missing
    defs = { :a => [:required], :b => [:permitted] }
    params = { :b => 2, :c => 3 }
    assert_raise ParamGuard::ParameterMissing do
      filtered = ParamGuard.filter(params, defs)
    end
  end

  def test_filter_raises_error_if_param_of_wrong_type
    defs = { :a => [:required, :string] }
    params = { :a => 1 }
    assert_raise ParamGuard::ParameterOfInvalidType do
      filtered = ParamGuard.filter(params, defs)
    end
  end

  def test_filter_raises_error_if_param_of_wrong_type_multiple_types_allowed
    defs = { :a => [:required, [:string, :integer]] }
    params = { :a => {} }
    assert_raise ParamGuard::ParameterOfInvalidType do
      filtered = ParamGuard.filter(params, defs)
    end
  end

  def test_filter_when_param_of_matches_any_type
    defs = { :a => [:required, [:string, :integer]] }
    params = { :a => 1 }
    filtered = ParamGuard.filter(params, defs)
    assert_equal({ :a => 1 }, filtered)
  end

  def test_filter_raises_error_if_missing_parameter_in_nested_definition
    defs = {
      :user => [:required, :hash, {
        :name => [:required, :string]
      }]
    }
    params = { :user => {} }
    assert_raise ParamGuard::ParameterMissing do
      filtered = ParamGuard.filter(params, defs)
    end
  end

  def test_filter_returns_only_valid_parameters_in_nested_definition
    defs = {
      :user => [:required, :hash, {
        :name => [:required, :string]
      }]
    }
    params = { :user => { :name => 'Bob', :email => 'bob@example.com' } }
    filtered = ParamGuard.filter(params, defs)
    assert_equal({ :user => { :name => 'Bob' } }, filtered)
  end

  def test_filter_accept_multiparams
    defs = {
      dob: [:required, :multi]
    }
    params = { "dob(1i)" => 1999, "dob(2i)" => 1, "dob(3i)" => 1 }
    filtered = ParamGuard.filter(params, defs)
    assert_equal params, filtered
  end

  def test_filter_accept_multiparams_when_scalar_or_multi_expected
    defs = {
      dob: [:required, [:scalar, :multi]]
    }
    params = { "dob(1i)" => "1999", "dob(2i)" => "1", "dob(3i)" => "1" }
    filtered = ParamGuard.filter(params, defs)
    assert_equal params, filtered
  end

  def test_filter_accept_scalar_when_scalar_or_multi_expected
    defs = {
      dob: [:required, [:scalar, :multi]]
    }
    params = { "dob" => "1999-01-01" }
    filtered = ParamGuard.filter(params, defs)
    assert_equal params, filtered
  end

  def test_filter_raise_if_not_multiparams_given
    defs = {
      dob: [:required, :multi]
    }
    params = { "dob" => "1999-01-02" }
    assert_raise ParamGuard::ParameterOfInvalidType do
      filtered = ParamGuard.filter(params, defs)
    end
  end

  def test_filter_accept_multiparams_or_scalar
    defs = {
      dob: [:required, [:scalar, :multi]]
    }
    params = { "dob" => "1999-01-02" }
    filtered = ParamGuard.filter(params, defs)
    assert_equal params, filtered
  end

  def test_filter_does_not_alter_original_params_object
    defs = { :a => [:required] }
    params = { :a => 1, :b => 2 }
    filtered = ParamGuard.filter(params, defs)
    assert_equal({ :a => 1, :b => 2 }, params)
    assert_equal({ :a => 1 }, filtered)
  end
end
