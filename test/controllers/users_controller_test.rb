require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @internal_auth = auth_configs(:internal)
    @target = users(:regular)
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  # ----- admin gate: every action requires an admin user -----

  test 'unauthenticated index redirects to login' do
    get users_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'manager cannot list users' do
    login_as 'manager'
    get users_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'hr cannot list users' do
    login_as 'hruser'
    get users_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot list users' do
    login_as 'regular'
    get users_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'manager cannot view a user' do
    login_as 'manager'
    get user_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'manager cannot edit a user' do
    login_as 'manager'
    get edit_user_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'manager cannot create a user' do
    login_as 'manager'
    assert_no_difference -> { User.count } do
      post users_path, params: { user: valid_user_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'manager cannot update a user' do
    login_as 'manager'
    patch user_path(@target), params: { user: { first_name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Regular', @target.reload.first_name
  end

  test 'manager cannot destroy a user' do
    login_as 'manager'
    assert_no_difference -> { User.count } do
      delete user_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  # ----- admin happy paths -----

  test 'admin can list users' do
    login_as 'admin'
    get users_path
    assert_response :success
  end

  test 'admin can view a user' do
    login_as 'admin'
    get user_path(@target)
    assert_response :success
  end

  test 'admin can render the new user form' do
    login_as 'admin'
    get new_user_path
    assert_response :success
  end

  test 'admin can create a user' do
    login_as 'admin'
    assert_difference -> { User.count }, 1 do
      post users_path, params: { user: valid_user_attrs }
    end
    assert_redirected_to user_path(User.last)
  end

  test 'admin can update a users non-credential fields' do
    login_as 'admin'
    patch user_path(@target), params: { user: { first_name: 'Renamed' } }
    assert_redirected_to user_path(@target)
    assert_equal 'Renamed', @target.reload.first_name
  end

  test 'admin can rotate a users password and the new password authenticates' do
    login_as 'admin'
    patch user_path(@target), params: {
      user: { password: 'NewPass!1', password_confirmation: 'NewPass!1' }
    }
    assert_redirected_to user_path(@target)
    assert @target.reload.authenticate('NewPass!1'), 'new password should authenticate'
    assert_not @target.authenticate('password'), 'old password should no longer authenticate'
  end

  test 'admin can destroy a user' do
    login_as 'admin'
    assert_difference -> { User.count }, -1 do
      delete user_path(@target)
    end
    assert_redirected_to users_path
  end

  # ----- credential leakage in JSON -----
  #
  # The default ActiveRecord JSON serializer dumps every column. For the User
  # model that includes password_digest and api_key, both of which are secrets.
  # These tests document the expected behavior — if they fail, the controller
  # needs to filter the serialized fields.

  test 'json show does not leak password_digest' do
    @target.update_columns(api_key: 'leaky-key')
    login_as 'admin'
    get user_path(@target, format: :json)
    assert_response :success
    body = response.body
    assert_no_match(/password_digest/, body)
    assert_no_match(/api_key/, body)
    assert_no_match(/leaky-key/, body)
  end

  test 'json index does not leak password_digest' do
    @target.update_columns(api_key: 'leaky-key-2')
    login_as 'admin'
    get users_path(format: :json)
    assert_response :success
    body = response.body
    assert_no_match(/password_digest/, body)
    assert_no_match(/api_key/, body)
    assert_no_match(/leaky-key-2/, body)
  end

  private

  def valid_user_attrs
    {
      first_name: 'New',
      last_name: 'User',
      user_name: 'new.user',
      auth_name: 'new.user',
      auth_config_id: @internal_auth.id,
      password: 'TempPass!1',
      password_confirmation: 'TempPass!1',
      active: true
    }
  end
end
