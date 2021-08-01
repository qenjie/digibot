$LOAD_PATH << File.expand_path('../lib', __dir__)
$LOAD_PATH << File.expand_path('../lib/digibot', __dir__)

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.start do
  add_filter '/spec/'
  track_files 'lib/**/*.rb'
end

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]

require 'digibot'
require 'digibot/command'

require 'pry'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
