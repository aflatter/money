$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'exporter/xml'
require 'money'

class MoneyTest < Test::Unit::TestCase
  
  def setup
    
    @can1  = Money.ca_dollar(100)
    @can2  = Money.ca_dollar(200)
    @can3  = Money.ca_dollar(300)
    @us1   = Money.us_dollar(100)
    
  end
  
  def test_sanity

    assert_equal @can1, @can1
    assert_equal true, @can1 < @can2
    assert_equal true, @can3 > @can2
    assert_equal [@can1, @can2, @can3], [@can1, @can2, @can3]
    assert_equal [@can1, @can2, @can3], [@can3, @can2, @can1].sort
    assert_not_equal [@can1, @can2, @can3], [@can3, @can2, @can1]
    assert_equal [@can1], [@can1, @can2, @can3] & [@can1]

    assert_equal [@can1, @can2], [@can1] | [@can2]

    
    assert_equal @can3, @can1 + @can2
    assert_equal @can1, @can2 - @can1
    
    assert_equal Money.ca_dollar(500), Money.ca_dollar(10) + Money.ca_dollar(90) + Money.ca_dollar(500) - Money.ca_dollar(100)
      
  end
  
  def test_convert
        
    assert_equal true, @can1 < @us1
    assert_equal Money.ca_dollar(114), @us1.exchange_to("CAD") 
    assert_equal Money.ca_dollar(114), @us1 
    assert_equal Money.us_dollar(85), @can1.exchange_to("USD") 
    assert_equal Money.us_dollar(85), @can1         
  end
  
  def test_multiply    
    assert_equal Money.ca_dollar(5500), Money.ca_dollar(100) * 55    
    assert_equal Money.ca_dollar(150), Money.ca_dollar(100) * 1.50
    assert_equal Money.ca_dollar(50), Money.ca_dollar(100) * 0.50
  end

  def test_divide
    assert_equal Money.ca_dollar(100), Money.ca_dollar(5500) / 55    
    assert_equal Money.ca_dollar(100), Money.ca_dollar(200) / 2    
  end
  
  def test_formatting

    assert_equal "free", Money.ca_dollar(0).format
    assert_equal "$1.00", @can1.format 
    assert_equal "$1.00 CAD", @can1.format(:with_currency)
    assert_equal "$0.85 USD", @can1.as_us_dollar.format(:with_currency)

    assert_equal "$1", @can1.format(:no_cents)
    assert_equal "$5", Money.ca_dollar(570).format(:no_cents)

    assert_equal "$5 CAD", Money.ca_dollar(570).format([:no_cents, :with_currency])
    assert_equal "$390", Money.ca_dollar(39000).format(:no_cents)

    assert_equal "$5.70 <span class=\"currency\">CAD</span>", Money.ca_dollar(570).format([:html, :with_currency])
    
  end
    
  def test_xml
    
    assert_equal 3752 * 3 / 0.75, (Money.ca_dollar(3752) * 3 / 0.75).cents
    
    xml = XmlExporter.new    
    Money.ca_dollar(1000).export(xml)
    assert_equal "<money currency='CAD'>1000</money>", xml.to_s

    xml = XmlExporter.new    
    Money.us_dollar(1000).export(xml)
    assert_equal "<money currency='USD'>1000</money>", xml.to_s
    
    
  end
  
  
end
