require 'faraday'
require 'faraday_middleware'
require 'em-synchrony'
require 'em-synchrony/em-http'

require 'exchange'
require 'strategy'

module Digibot
  class Reactor

    def initialize(config)
      @shutdown = false
      @strategy = Digibot::Strategy.create(config)
      @dax = build_dax(config)

      trap('INT') { stop }
    end

    def build_dax(config)
      dax = {}
      config['sources'].each { |ex|
        dax[ex['driver'].to_sym] = Digibot::Exchange.create(ex)
      }

      dax[:target] = Digibot::Exchange.create(config['target'])

      return dax
    end

    def run
      strategy_delay = @dax.collect { |_k, v| v.min_delay }.min

      EM.synchrony do
        @dax.each do |name, exchange|
          Digibot::Log.debug "Starting Exchange: #{name}"

          exchange.timer = EM::Synchrony::add_periodic_timer(exchange.min_delay) do
            exchange.queue.pop do |action|
              Digibot::Log.debug "Scheduling Action #{Time.now} - Exchange #{name} Delay #{exchange.min_delay} - Queue size: #{exchange.queue.size}"
              Digibot::Log.debug "pop: #{action}"
              schedule(action)
            end
          end

          exchange.start
        end

        @timer = EM::Synchrony::add_periodic_timer(strategy_delay) do
          execute_strategy if queues_empty?
        end
      end
    end

    def queues_empty?
      queue_sizes = @dax.collect { |_k, v| v.queue.size }
      queue_sizes.max.zero?
    end

    def execute_strategy
      Digibot::Log.debug "Calling Strategy #{Time.now}"
      @strategy.call(@dax) do |action|
        @dax[action.destination].queue.push(action)
      end
    end

    def schedule(action)
      case action.type
      when :ping
        @target.ping
      when :order_create
        @dax[action.destination].create_order(action.params[:order])
      when :order_stop
        @dax[action.destination].stop_order(action.params[:id])
      else
        Digibot::Log.error "Unknown Action type: #{action.type}"
      end
    end

    def stop
      puts 'Shutdown trading'
      @shutdown = true
      @timer.cancel
      @dax.each { |_name, exchange| exchange.timer.cancel }
      EM.stop
    end
  end
end
