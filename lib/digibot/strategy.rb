require 'strategy/base'
require 'strategy/copy'

module Digibot
  module Strategy
    def self.create(config)
      strategy_class(config['type']).new(config)
    end

    def self.strategy_class(type)
      Digibot::Strategy.const_get(type.capitalize)
    end
  end
end
