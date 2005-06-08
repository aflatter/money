$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'money'

class NoExchangeBankTest < Test::Unit::TestCase
  
  def setup
    @bank = NoExchangeBank.new
  end
  
  def test_exchange    
    assert_raise(Money::MoneyError) do
      @bank.reduce(Money.us_dollar(100), "CAD")
    end
  end
  
end
