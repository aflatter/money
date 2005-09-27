$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'money'

class CoreExtensionsTest < Test::Unit::TestCase

  def setup
  end

  def test_numeric_conversion    
    assert_equal Money.new(10000), 100.to_money
    assert_equal Money.new(10038), 100.38.to_money
    assert_equal Money.new(-10000), -100.to_money
  end
    
  def test_string_conversion
    assert_equal Money.new(100), "$1".to_money
    assert_equal Money.new(100), "$1.00".to_money
    assert_equal Money.new(137), "$1.37".to_money
    assert_equal Money.new(100, 'CAD'), "CAD $1.00".to_money
    assert_equal Money.new(-10000), "-100".to_money
    assert_equal Money.new(410), "4.10".to_money
  end
  
  def test_nil
    assert_equal Money.empty, nil.to_money
  end

end