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

  # ----- session reset paths -----

  test "GET /login clears any existing session" do
    # Seed a valid session first.
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    assert_not_nil session[:user_id]

    # Hitting /login resets the session (LoginController#index calls
    # reset_session). Dashboard access should then bounce back to login.
    get login_path
    assert_response :success
    assert_nil session[:user_id]

    get dashboard_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "attempt_login clears any prior session before processing the new attempt" do
    # Log in as admin.
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    admin_id = session[:user_id]
    assert_not_nil admin_id

    # Now fire a failed attempt. The controller calls reset_session BEFORE
    # authenticating, so even though the attempt fails, the admin's prior
    # session must be gone — the user should end up logged out rather
    # than silently still logged in as admin.
    post login_attempt_login_path, params: { username: 'ghost', password: 'wrong' }
    assert_nil session[:user_id]

    get dashboard_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "blank username is rejected" do
    post login_attempt_login_path, params: { username: '', password: 'password' }
    assert_redirected_to action: :index
    assert_nil session[:user_id]
  end

  test "valid credentials work for every non-inactive role fixture" do
    # A regression guard: if someone adds a new role check or reshapes
    # AuthConfig and accidentally breaks one role's login path, this
    # test will fail loudly instead of silently.
    %w[admin manager hruser regular self.candidate].each do |username|
      post login_attempt_login_path, params: { username: username, password: 'password' }
      assert_redirected_to dashboard_path,
                           "expected #{username} to reach dashboard on login"
      assert_not_nil session[:user_id], "expected #{username} to have a session id"
      # Clean the session between iterations so each role is tested from
      # a clean slate.
      reset!
    end
  end
end
