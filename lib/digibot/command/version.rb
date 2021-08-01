module Digibot
  module Command
    class Version < Clamp::Command
      def execute
        puts "Digibot version #{read_version}"
      end

      def read_version
        File.read(File.expand_path('../../../VERSION', __dir__))
      end
    end
  end
end
