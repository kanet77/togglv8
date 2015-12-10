require "simplecov"
require "coveralls"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'pry-byebug'

require_relative 'togglv8_spec_helper'
require_relative '../lib/togglv8'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.filter_run :focus
  config.filter_run_excluding :pro_account unless ENV['TOGGL_PRO_ACCOUNT']
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    toggl = TogglV8::API.new(Testing::API_TOKEN)
    TogglV8SpecHelper.setUp(toggl)
  end
end

class Testing
  API_TOKEN = ENV['API_TOKEN'] || '4880adbe1bee9a241fa08070d33bd49f'
  USERNAME  = ENV['USERNAME']  || 'togglv8@mailinator.com'
  PASSWORD  = ENV['PASSWORD']  || 'togglv8'
  USER_ID   = (ENV['USER_ID']  || 1820939).to_i
end
