require 'mtgox/bid'
require 'mtgox/price_ticker'

module MtGox
  class MaxBid < Bid
    include PriceTicker
  end
end
