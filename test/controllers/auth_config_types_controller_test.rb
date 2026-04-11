require 'test_helper'

class AuthConfigTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = auth_config_types(:internal)
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  # ----- admin gate: every action requires admin -----

  test 'unauthenticated index redirects to login' do
    get auth_config_types_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'manager cannot list auth config types' do
    login_as 'manager'
    get auth_config_types_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'hr cannot list auth config types' do
    login_as 'hruser'
    get auth_config_types_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot list auth config types' do
    login_as 'regular'
    get auth_config_types_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'manager cannot view an auth config type' do
    login_as 'manager'
    get auth_config_type_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'manager cannot create an auth config type' do
    login_as 'manager'
    assert_no_difference -> { AuthConfigType.count } do
      post auth_config_types_path, params: { auth_config_type: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'manager cannot update an auth config type' do
    login_as 'manager'
    patch auth_config_type_path(@target), params: { auth_config_type: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Internal', @target.reload.name
  end

  test 'manager cannot destroy an auth config type' do
    login_as 'manager'
    assert_no_difference -> { AuthConfigType.count } do
      delete auth_config_type_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  # ----- admin happy paths -----

  test 'admin can list auth config types' do
    login_as 'admin'
    get auth_config_types_path
    assert_response :success
  end

  test 'admin can view an auth config type' do
    login_as 'admin'
    get auth_config_type_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_auth_config_type_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_auth_config_type_path(@target)
    assert_response :success
  end

  test 'admin can create an auth config type' do
    login_as 'admin'
    assert_difference -> { AuthConfigType.count }, 1 do
      post auth_config_types_path, params: { auth_config_type: valid_attrs }
    end
    assert_redirected_to auth_config_type_path(AuthConfigType.last)
  end

  test 'admin can update an auth config type' do
    login_as 'admin'
    patch auth_config_type_path(@target), params: { auth_config_type: { name: 'Renamed' } }
    assert_redirected_to auth_config_type_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy an auth config type' do
    login_as 'admin'
    # Destroying the only auth_config_type would cascade-break the auth_configs
    # fixture's foreign key, so create a fresh row to delete instead.
    fresh = AuthConfigType.create!(code: 'TMP', name: 'Temporary', description: 'For deletion')
    assert_difference -> { AuthConfigType.count }, -1 do
      delete auth_config_type_path(fresh)
    end
    assert_redirected_to auth_config_types_path
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get auth_config_types_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get auth_config_type_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'LDAP', name: 'LDAP', description: 'LDAP authentication' }
  end
end
