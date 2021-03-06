require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include Capybara::DSL
  Capybara.default_driver = :selenium
  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = false
end
