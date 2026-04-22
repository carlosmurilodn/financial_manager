ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module AuthenticationTestHelper
  def sign_in_test_user
    user = User.create!(
      email: "test-#{SecureRandom.hex(8)}@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post login_path, params: {
      email: user.email,
      password: "password123"
    }

    user
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Keep tests independent from fixture-wide truncation so they work with a
    # regular local PostgreSQL role that does not have superuser privileges.
    self.use_transactional_tests = true

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationTestHelper

  setup do
    sign_in_test_user unless %w[SessionsControllerTest UsersControllerTest].include?(self.class.name)
  end
end
