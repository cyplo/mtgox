require 'mtgox/order'

module MtGox
  class Trade < Order

    def initialize(trade={}, currency)
      self.id     = trade['tid'].to_i
      self.date   = Time.at(trade['date'].to_i)
      self.amount = trade['amount'].to_f
      self.price  = trade['price'].to_f
      self.currency = currency
    end
  end
end
