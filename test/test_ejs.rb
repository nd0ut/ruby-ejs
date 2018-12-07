require "ejs"
require "test/unit"

FUNCTION_PATTERN = /^function\s*\(.*?\)\s*\{(.*?)\};$/

module TestHelper
  def test(name, &block)
    define_method("test #{name.inspect}", &block)
  end
end

class EJSCompilationTest < Test::Unit::TestCase
  extend TestHelper

  test "compile" do
    result = EJS.compile("Hello <%= name %>")
    assert_match FUNCTION_PATTERN, result
    assert_no_match(/Hello \<%= name %\>/, result)
  end
end

class EJSEvaluationTest < Test::Unit::TestCase
  extend TestHelper

  test "function calls" do
    template = "<%= t('foo') %>"
    assert_equal "bar", EJS.evaluate(template, :t => lambda{ 'bar' })
  end

  test "simple variable" do
    template = "<%= name %>"
    assert_equal "Name", EJS.evaluate(template, :name => 'Name')
  end

  test "deep object" do
    template = "<%= deep.variable %>"
    assert_equal "Deep.Variable", EJS.evaluate(template, :deep => {:variable => 'Deep.Variable'})
  end

  test "simple logic" do
    template = "<%= foo || 'default' %> <%= bar || 'default' %>"
    assert_equal "default bar", EJS.evaluate(template, :bar => 'bar')
  end

  test "simple if statements" do
    template = "<% if(crop) { %>DO CROP<% } %>"
    assert_equal "DO CROP", EJS.evaluate(template, :crop => 1)
  end

end
