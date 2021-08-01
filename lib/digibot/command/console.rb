require 'pry'

module Digibot
  module Command
    class Console < Clamp::Command

      def execute
        Pry.hooks.add_hook(:before_session, 'digibot_load') do |output, binding, pry|
          output.puts "Digibot development console"
        end

        Pry.config.prompt_name = 'digibot'
        Pry.config.requires = ['openssl']
        Pry.start
      end
    end
  end
end
