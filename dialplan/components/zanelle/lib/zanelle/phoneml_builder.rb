class PhonemlBuilder
  METHODS = [:dial, :speak, :play, :input, :record, :transfer, :goto, :hangup]
  def self.start; yield(o = PhoneMLBuilder.new); o.json; end
  def initialize; @data = {'phoneml' => []}; end
  def data; @data['phoneml']; end
  def json; @data.to_json; end
  def dial; @data.to_json; end
  def hangup; data << {'hangup' => {"$" => ""}}; end
  def method_missing(sym, arg, *rest, &block)
    if METHODS.include?(sym);
      h={"$"=>arg}
      rest.each { |r| h.merge!(r) }
      data << { sym.to_s=>h }
    else
      super
    end
  end
end
