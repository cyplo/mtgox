require 'mtgox/price_ticker'
require 'singleton'

module MtGox
  class Ticker
    include PriceTicker
    attr_accessor :buy, :sell, :high, :low, :volume, :vwap
  end
end
