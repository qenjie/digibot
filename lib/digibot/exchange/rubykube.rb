require 'exchange/base'
require 'open_orders'

module Digibot::Exchange
  class Rubykube < Base
    def initialize(config)
      super
      @margin = config['spread']
      @decimalprice = config['decimalprice']
      @decimalamount = config['decimalamount']
      @connection = Faraday.new("#{config['host']}/api/v2") do |builder|
        builder.response :json
        builder.adapter :em_synchrony
      end
    end

    # Ping the api
    def ping
      @connection.get '/barong/identity/ping'
    end

    def create_order(order)
      price = order.price + (@margin * order.price) 
      if(order.side.to_s == 'buy')
        price = order.price - (@margin * order.price) 
      end
      response = post(
        'peatio/market/orders',
        {
          market: order.market.downcase,
          side:   order.side.to_s,
          volume: order.amount.round(@decimalamount),
          price:  price.round(@decimalprice)
        }
      )
      @open_orders.add_order(order, response.env.body['id']) if response.env.status == 201 && response.env.body['id']

      response
    end

    def stop_order(id)
      response = post(
        "peatio/market/orders/#{id}/cancel"
      )
      @open_orders.remove_order(id)

      response
    end

    private

    def post(path, params = nil)
      response = @connection.post do |req|
        req.headers = generate_headers
        req.url path
        req.body = params.to_json
      end
      Digibot::Log.fatal(build_error(response)) if response.env.status != 201
      response
    end

    def generate_headers
      nonce = (Time.now.to_f * 1000 + 2000).to_i.to_s
      {
        'X-Auth-Apikey' => @api_key,
        'X-Auth-Nonce' => nonce,
        'X-Auth-Signature' => OpenSSL::HMAC.hexdigest('SHA256', @secret, nonce + @api_key),
        'Content-Type' => 'application/json'
      }
    end
  end
end
