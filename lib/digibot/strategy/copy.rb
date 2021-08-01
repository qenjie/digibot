require 'action'

module Digibot::Strategy
  class Copy < Base

    def call(dax, &block)
      sources = dax.select { |k, _v| k != :target }
      ob = merge_orderbooks(sources, dax[:target].market)
      ob = scale_amounts(ob)

      open_orders = dax[:target].open_orders
      diff = open_orders.get_diff(ob)

      [:buy, :sell].each do |side|
        create = diff[:create][side]
        delete = diff[:delete][side]
        update = diff[:update][side]


        if !create.length.zero?
          order = create.first
          yield Digibot::Action.new(:order_create, :target, { order: order })
        elsif !delete.length.zero?
          yield Digibot::Action.new(:order_stop, :target, { id: delete.first })
        elsif !update.length.zero?
          order = update.first
          if order.amount > 0.0001
            yield Digibot::Action.new(:order_create, :target, { order: order })
          else
            new_amount = open_orders.price_amount(side, order.price) + order.amount
            new_order = Digibot::Order.new(order.market, order.price, new_amount, order.side)

            open_orders.price_level(side, order.price).each do |id, _ord|
              yield Digibot::Action.new(:order_stop, :target, { id: id })
            end

            yield Digibot::Action.new(:order_create, :target, { order: new_order })
          end
        end
      end
    end

    def scale_amounts(orderbook)
      ob = Digibot::Orderbook.new(orderbook.market)

      [:buy, :sell].each do |side|
        orderbook[side].each do |price, amount|
          ob[side][price] = amount * @volume_ratio
        end
      end

      ob
    end

    def merge_orderbooks(sources, market)
      ob = Digibot::Orderbook.new(market)

      sources.each do |_key, source|
        source_book = source.orderbook.clone

        source_book[:sell].shift
        source_book[:buy].shift

        ob.merge!(source_book)
      end

      ob
    end
  end
end
