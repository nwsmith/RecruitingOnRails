ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Parallelization is intentionally OFF.
  #
  # Tried both options and neither works without infrastructure changes
  # outside this repo:
  #
  #   parallelize(workers: :number_of_processors)            # processes
  #     — Rails creates per-worker databases like
  #       RecruitingOnRails_test-1, -2, etc. The `recruiting` MySQL user
  #       only has privileges on RecruitingOnRails_test, so the worker
  #       database creation fails with a permission error and 697 tests
  #       blow up at fixture-loading time. Fix: GRANT CREATE on
  #       `RecruitingOnRails_test%`.* to recruiting@localhost in MySQL
  #       and re-enable.
  #
  #   parallelize(workers: :number_of_processors, with: :threads)
  #     — mysql2's C extension isn't safe to share across threads;
  #       connections get into a "MySQL client is not connected" state
  #       when multiple threads check out from the pool simultaneously.
  #       This is a known issue with mysql2 — switching to
  #       `trilogy` would fix it.
  #
  # The 128s sequential suite is acceptable for now. Re-enable when
  # either of the above is addressed.
  # parallelize(workers: :number_of_processors)

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
