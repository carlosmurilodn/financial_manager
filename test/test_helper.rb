ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Keep tests independent from fixture-wide truncation so they work with a
    # regular local PostgreSQL role that does not have superuser privileges.
    self.use_transactional_tests = true

    # Add more helper methods to be used by all tests here...
  end

  class ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
