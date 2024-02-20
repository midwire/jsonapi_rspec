# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'pry'
require 'bundler/setup'
require 'jsonapi_rspec'

require 'rack'

Dir[JsonapiRspec.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.mock_with :rspec
  config.color = true
  config.order = 'random'
  config.profile_examples = 3
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Shorten the standard RSpec expectation failure exception
  ExpectationNotMetError = RSpec::Expectations::ExpectationNotMetError

  # Make meta not-required by default for the tests, otherwise it may get
  # set to true and remain that way for another test.
  config.before do
    JsonapiRspec.configure do |c|
      c.meta_required = false
    end
  end

  # Build a response using the passed fixture name
  def response_with(fixture_name)
    json = File.read(JsonapiRspec.root.join('spec', 'fixtures', "#{fixture_name}_response.json"))
    res = Rack::Response.new
    res.body = json
    res
  end
end
