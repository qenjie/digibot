require 'command/start'
require 'command/console'
require 'command/version'

module Digibot
  module Command
    class Root < Clamp::Command
      subcommand 'start', 'Starting the bot', Start
      subcommand 'console', 'Start a development console', Console
      subcommand 'version', 'Print the Digibot version', Version
    end
  end
end
