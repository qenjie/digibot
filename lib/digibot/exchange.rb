require 'exchange/base'
require 'exchange/bitfinex'
require 'exchange/rubykube'
require 'exchange/bitfaker'
require 'exchange/binance'

module Digibot
  module Exchange
    def self.create(config)
      exchange_class(config['driver']).new(config)
    end

    def self.exchange_class(driver)
      Digibot::Exchange.const_get(driver.capitalize)
    end
  end
end
