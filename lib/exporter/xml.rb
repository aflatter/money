require 'rexml/document'

class XmlExporter
  
  def initialize(doc = REXML::Document.new)
    @last = @parent = @doc = doc
  end
  
  def add_text(key, obj)
    if obj.respond_to?(:export)
      enter_section(key) { obj.export(self) }
    else
      @last = @parent.add_element(key.to_s)
      @last.text = obj.to_s unless obj.to_s.empty?
    end
  end
  
  alias :add_textile :add_text
  
  def enter_section(key, &block)
    old = @parent
    @parent = @last = @parent.add_element(key.to_s)
    block.call
    @parent = @last = old
  end
  
  def add_attribute(key, obj)
    @last.add_attribute(key.to_s, obj.to_s)
  end
  
  def to_s(indent = -1)
    @doc.to_s(indent)
  end
  
end