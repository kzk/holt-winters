require 'holt_winters.rb'

class HoltWintersFactory
  def self.create(alpha, attrs={})
    if (attrs.has_key? :beta)
      HoltWintersDouble.new(alpha, attrs[:beta])
    elsif (attrs.has_key? :beta) && (attrs.has_key? :gamma) && (attrs.has_key? :period)
      HoltWintersTriple.new(alpha, attrs[:beta], attrs[:gamma], attrs[:period])
    else
      HoltWintersSimple.new(alpha)
    end
  end
end
