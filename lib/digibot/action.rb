module Digibot
  class Action
    attr_reader :type, :params, :destination
    def initialize(type, destination, params=nil)
      @type        = type
      @params      = params
      @destination = destination
    end

    def to_s
      "#Type: #{@type}, params: #{@params}"
    end
  end
end
