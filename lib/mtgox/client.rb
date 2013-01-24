require 'faraday/error'
require 'ostruct'
require 'mtgox/ask'
require 'mtgox/bid'
require 'mtgox/buy'
require 'mtgox/connection'
require 'mtgox/max_bid'
require 'mtgox/min_ask'
require 'mtgox/request'
require 'mtgox/sell'
require 'mtgox/ticker'
require 'mtgox/trade'

module MtGox
  class Client
    include MtGox::Connection
    include MtGox::Request

    ORDER_TYPES = {:sell => 1, :buy => 2}

    # Fetch a deposit address
    # @authenticated true
    # @return [String]
    # @example
    #   MtGox.address
    def address
      post('/api/0/btcAddress.php')['addr']
    end


    # Fetch the latest ticker data
    #
    # @authenticated false
    # @return [MtGox::Ticker]
    # @example
    #   MtGox.ticker
    def ticker(currency)
      ticker = get('/api/0/data/ticker.php', "Currency" => currency)['ticker']
      t = Ticker.new
      t.buy    = ticker['buy'].to_f
      t.high   = ticker['high'].to_f
      t.price  = ticker['last'].to_f
      t.low    = ticker['low'].to_f
      t.sell   = ticker['sell'].to_f
      t.volume = ticker['vol'].to_f
      t.vwap   = ticker['vwap'].to_f
      t
    end

    # Fetch both bids and asks in one call, for network efficiency
    #
    # @authenticated false
    # @return [Hash] with keys :asks and :asks, which contain arrays as described in {MtGox::Client#asks} and {MtGox::Clients#bids}
    # @example
    #   MtGox.offers(currency)
    def offers(currency)
      offers = get('/api/0/data/getDepth.php', "Currency" => currency)
      asks = offers['asks'].sort_by do |ask|
        ask[0].to_f
      end.map! do |ask|
        Ask.new(*ask)
      end
      bids = offers['bids'].sort_by do |bid|
        -bid[0].to_f
      end.map! do |bid|
        Bid.new(*bid)
      end
      {:asks => asks, :bids => bids}
    end

    # Fetch open asks
    #
    # @authenticated false
    # @return [Array<MtGox::Ask>] an array of open asks, sorted in price ascending order
    # @example
    #   MtGox.asks
    def asks(currency)
      offers(currency)[:asks]
    end

    # Fetch open bids
    #
    # @authenticated false
    # @return [Array<MtGox::Bid>] an array of open bids, sorted in price descending order
    # @example
    #   MtGox.bids
    def bids(currency)
      offers(currency)[:bids]
    end

    # Fetch the lowest priced ask
    #
    # @authenticated false
    # @return [MtGox::MinAsk]
    # @example
    #   MtGox.min_ask
    def min_ask(currency)
      min_ask = asks(currency).first
      m = MinAsk.new
      m.price = min_ask.price
      m.amount = min_ask.amount
      m.currency = currency
      m
    end

    # Fetch the highest priced bid
    #
    # @authenticated false
    # @return [MtGox::MinBid]
    # @example
    #   MtGox.max_bid
    def max_bid(currency)
      max_bid = bids.first
      m = MaxBid.new
      m.price = max_bid.price
      m.amount = max_bid.amount
      m.currency = currency
      m
    end

    # Fetch recent trades
    #
    # @authenticated false
    # @return [Array<MtGox::Trade>] an array of trades, sorted in chronological order
    # @example
    #   MtGox.trades
    def trades(currency)
      get('/api/0/data/getTrades.php', {'Currency' => currency}).sort_by{|trade| trade['date']}.map do |trade|
        Trade.new(trade, currency)
      end
    end

    # Fetch your info
    #
    # @authenticated true
    # @example
    #   MtGox.getinfo
    def info
      post('/api/0/info.php')
    end

    def balance
      ret = {}
      info["Wallets"].each {|currency, details|
        ret[currency] = details["Balance"]["value"].to_f
      }
      ret
    end

    def history(currency)
      OpenStruct.new post("api/1/BTC#{currency}/private/trades")
    end

    # Fetch your open orders, both buys and sells, for network efficiency
    #
    # @authenticated true
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   MtGox.orders
    def orders
      parse_orders(post('/api/0/getOrders.php')['orders'])
    end

    # Fetch your open buys
    #
    # @authenticated true
    # @return [Array<MtGox::Buy>] an array of your open bids, sorted by date
    # @example
    #   MtGox.buys
    def buys
      orders[:buys]
    end

    # Fetch your open sells
    #
    # @authenticated true
    # @return [Array<MtGox::Sell>] an array of your open asks, sorted by date
    # @example
    #   MtGox.sells
    def sells
      orders[:sells]
    end

    # Place a limit order to buy BTC
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to purchase
    # @param price [Numeric] the bid price in US dollars
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   # Buy one bitcoin for $0.011
    #   MtGox.buy! 1.0, 0.011
    def buy!(amount, price, currency)
      parse_orders(post('/api/0/buyBTC.php', {:amount => amount, :price => price, "Currency" => currency})['orders'])
    end

    # Place a limit order to sell BTC
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to sell
    # @param price [Numeric] the ask price in US dollars
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   # Sell one bitcoin for $100
    #   MtGox.sell! 1.0, 100.0
    def sell!(amount, price, currency)
      parse_orders(post('/api/0/sellBTC.php', {:amount => amount, :price => price, "Currency" => currency})['orders'])
    end

    # Cancel an open order
    #
    # @authenticated true
    # @overload cancel(oid)
    #   @param oid [String] an order ID
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order.oid
    #     MtGox.cancel 1234567890
    # @overload cancel(order)
    #   @param order [Hash] a hash-like object, with keys `oid` - the order ID of the transaction to cancel and `type` - the type of order to cancel (`1` for sell or `2` for buy)
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order
    #     MtGox.cancel {'oid' => '1234567890', 'type' => 2}
    def cancel(args)
      if args.is_a?(Hash)
        order = args.delete_if{|k, v| !['oid', 'type'].include?(k.to_s)}
        parse_orders(post('/api/0/cancelOrder.php', order)['orders'])
      else
        orders = post('/api/0/getOrders.php', {})['orders'] # is this OK for multicurrency?
        order = orders.find{|order| order['oid'] == args.to_s}
        if order
          order = order.delete_if{|k, v| !['oid', 'type'].include?(k.to_s)}
          parse_orders(post('/api/0/cancelOrder.php', order)['orders'])
        else
          raise Faraday::Error::ResourceNotFound, {:status => 404, :headers => {}, :body => 'Order not found.'}
        end
      end
    end

    # Transfer bitcoins from your Mt. Gox account into another account
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to withdraw
    # @param btca [String] the bitcoin address to send to
    # @return [Array<MtGox::Balance>]
    # @example
    #   # Withdraw 1 BTC from your account
    #   MtGox.withdraw! 1.0, '1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L'
    def withdraw!(amount, btca)
      parse_balance(post('/api/0/withdraw.php', {:group1 => 'BTC', :amount => amount, :btca => btca}))
    end

    private

    def parse_orders(orders)
      buys = []
      sells = []
      orders.sort_by{|order| order['date']}.each do |order|
        case order['type']
        when ORDER_TYPES[:sell]
          s = Sell.new(order)
          sells << s
        when ORDER_TYPES[:buy]
          b = Buy.new(order)
          buys << b
        end
      end
      {:buys => buys, :sells => sells}
    end
  end
end
