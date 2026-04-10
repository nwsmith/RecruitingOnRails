require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  test "login page renders" do
    get login_path
    assert_response :success
  end

  test "successful login redirects to dashboard" do
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    assert_redirected_to dashboard_path
    assert_not_nil session[:user_id]
  end

  test "failed login redirects to login page" do
    post login_attempt_login_path, params: { username: 'admin', password: 'wrong' }
    assert_redirected_to action: :index
    assert_nil session[:user_id]
  end

  test "inactive user cannot login" do
    post login_attempt_login_path, params: { username: 'inactive', password: 'password' }
    assert_redirected_to action: :index
    assert_nil session[:user_id]
  end

  test "unknown user cannot login" do
    post login_attempt_login_path, params: { username: 'nobody', password: 'password' }
    assert_redirected_to action: :index
  end

  test "login sets session expiry" do
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    assert_not_nil session[:expires_at]
  end
end
