require 'faraday'
require 'faraday/request/url_encoded'
require 'faraday/response/raise_error'
require 'faraday/response/raise_mtgox_error'
require 'faraday_middleware'
require 'faraday_middleware/response/parse_json'
require 'mtgox/version'

module MtGox
  module Connection
    private

    def connection
      options = {
        :headers  => {
          :accept => 'application/json',
          :user_agent => "mtgox gem #{MtGox::Version} (modified)",
        },
        :ssl => {:verify => false},
        :url => 'https://mtgox.com',
      }

      Faraday.new(options) do |connection|
        connection.request :url_encoded
        connection.use Faraday::Response::RaiseError
        connection.use FaradayMiddleware::ParseJson
        connection.use Faraday::Response::RaiseMtGoxError
        connection.adapter(Faraday.default_adapter)
      end
    end
  end
end
