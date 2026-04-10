require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user is redirected to login" do
    get dashboard_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "expired session is redirected to login" do
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    # Simulate expired session by traveling forward in time
    travel 3.hours do
      get dashboard_path
      assert_redirected_to controller: 'login', action: 'index'
    end
  end

  test "authenticated user can access dashboard" do
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    get dashboard_path
    assert_response :success
  end

  test "session expiry is extended on each request" do
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    travel 1.hour do
      get dashboard_path
      assert_response :success
    end
    # Still valid 1 hour after the extension
    travel 2.hours do
      get dashboard_path
      assert_response :success
    end
  end
end
