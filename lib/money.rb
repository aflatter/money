# === Usage with ActiveRecord
# 
# Use the compose_of helper to let active record deal with embedding the money
# object in your models. The following example requires a cents and a currency field.
# 
#   class ProductUnit < ActiveRecord::Base
#     belongs_to :product
#     composed_of :price, :class_name => "Money", :mapping => %w(cents currency)
# 
#     private        
#       validate :cents_not_zero
#     
#       def cents_not_zero
#         errors.add("cents", "cannot be zero or less") unless cents > 0
#       end
#     
#       validates_presence_of :sku, :currency
#       validates_uniqueness_of :sku        
#   end
#   
class Money
  include Comparable
  attr_reader :cents, :currency

  DEFAULT = "CAD"

  EXCHANGE_RATES = { 
    "CAD_TO_USD" => 0.85,  
    "USD_TO_CAD" => 1.15,
  }

  # Creates a new money object. 
  #  Money.new(100) 
  # 
  # Alternativly you can use the convinience methods like 
  # Money.ca_dollar and Money.us_dollar 
  def initialize(cents, currency = DEFAULT)
    @cents, @currency = cents, currency
  end

  # Do two money objects equal? Only works if both objects are of the same currency
  def eql?(other_money)
    cents == other_money.cents && currency == other_money.currency
  end

  def <=>(other_money)
    if currency == other_money.currency
      cents <=> other_money.cents
    else
      cents <=> other_money.exchange_to(currency).cents
    end
  end
  
  def +(other_money)
    if currency == other_money.currency
      Money.new(cents + other_money.cents,currency)
    else
      Money.new(cents + other_money.exchange_to(currency).cents,currency)
    end   
  end

  def -(other_money)
    if currency == other_money.currency
      Money.new(cents - other_money.cents, currency)
    else
      Money.new(cents - other_money.exchange_to(currency).cents, currency)
    end   
  end
    
  # get the cents value of the object
  def cents
    @cents.to_i
  end
  
  # multiply money by fixnum
  def *(fixnum)
    Money.new(cents * fixnum, currency)    
  end

  # divide money by fixnum
  def /(fixnum)
    Money.new(cents / fixnum, currency)    
  end
  
  
  # Format the price according to several rules
  # Currently supported are :with_currency, :no_cents and :html
  #
  # with_currency: 
  #
  #  Money.ca_dollar(0).format => "free"
  #  Money.ca_dollar(100).format => "$1.00"
  #  Money.ca_dollar(100).format(:with_currency) => "$1.00 CAD"
  #  Money.us_dollar(85).format(:with_currency) => "$0.85 USD"
  #
  # no_cents:  
  #
  #  Money.ca_dollar(100).format(:no_cents) => "$1"
  #  Money.ca_dollar(599).format(:no_cents) => "$5"
  #  
  #  Money.ca_dollar(570).format([:no_cents, :with_currency]) => "$5 CAD"
  #  Money.ca_dollar(39000).format(:no_cents) => "$390"
  #
  # html:
  #
  #  Money.ca_dollar(570).format([:html, :with_currency]) =>  "$5.70 <span class=\"currency\">CAD</span>"
  def format(rules = [])
    return "free" if cents == 0
    
    rules = [rules].flatten
        
    if rules.include?(:no_cents)
      formatted = sprintf("$%d", cents.to_f / 100  )          
    else
      formatted = sprintf("$%.2f", cents.to_f / 100  )      
    end
    
    if rules.include?(:with_currency)
      formatted << " "
      formatted << '<span class="currency">' if rules.include?(:html)
      formatted << currency
      formatted << '</span>' if rules.include?(:html)
    end
    formatted
  end
  
  # Money.ca_dollar(100).to_s => "$1.00 CAD"
  def to_s
    format(:with_currency)
  end
  
  # Recieve the amount of this money object in another currency   
  def exchange_to(other_currency)
    rate = EXCHANGE_RATES["#{currency}_TO_#{other_currency}"] or raise "Can't find required exchange rate"
    
    exchanged_cents = (cents * rate).floor
    Money.new(exchanged_cents, other_currency)
  end  
  
  # Create a new money object with value 0
  def self.empty(currency = DEFAULT)
    Money.new(0, currency)
  end

  # Create a new money object using the Canadian dollar currency
  def self.ca_dollar(num)
    Money.new(num, "CAD")
  end

  # Create a new money object using the American dollar currency
  def self.us_dollar(num)
    Money.new(num, "USD")
  end
  
  # Recieve a money object with the same amount as the current Money object
  # in american dollar 
  def as_us_dollar
    exchange_to("USD")
  end
 
 # Recieve a money object with the same amount as the current Money object
 # in canadian dollar 
  def as_ca_dollar
    exchange_to("CAD")
  end

  # Export the money class
  # This is useful if you want to export Orders as XML as a means to get 
  # Them out of the dynamic DB and store them a bit more static 
  # ( Otherwise your completed orders would change in value when you put 
  # products on sale ) 
  # 
  #  xml = XmlExporter.new    
  #  Money.ca_dollar(1000).export(xml)
  #  xml.to_s => <money currency='CAD'>1000</money>
  def export(exporter)
    exporter.add_text("money", cents)
    exporter.add_attribute("currency", currency)
  end
  
end