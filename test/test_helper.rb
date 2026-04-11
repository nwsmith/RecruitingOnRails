ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
end

class ActionDispatch::IntegrationTest
  # Shared login helper for all controller / integration tests. The fixture
  # users (admin, manager, hruser, regular, self_candidate_user, inactive)
  # all share the bcrypt password "password"; passing one of those user_names
  # is enough to get an authenticated session.
  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end
end
