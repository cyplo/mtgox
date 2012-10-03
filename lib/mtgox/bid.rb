require 'mtgox/offer'

module MtGox
  class Bid < Offer

    def initialize(price=nil, amount=nil, currency=nil)
      self.price = price.to_f
      self.amount = amount.to_f
      self.currency = currency
    end

    def eprice
      price * (1 - MtGox.commission)
    end

  end
end
