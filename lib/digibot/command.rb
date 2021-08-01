require 'clamp'
require 'yaml'

require 'command/root'
require 'digibot'

module Digibot
  module Command
    def run!
      load_configuration
      Digibot::Log.define
      Root.run
    end
    module_function :run!

    def load_configuration
      config = YAML.load_file('config/strategy.yaml')

      Digibot::Configuration.define { |c| c.strategy = config['strategy'] }
    end
    module_function :load_configuration

  end
end
