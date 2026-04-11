require "test_helper"

class AuthConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @internal_type = auth_config_types(:internal)
    @target = auth_configs(:internal)
  end


  # ----- admin gate: every action requires admin -----

  test "unauthenticated index redirects to login" do
    get auth_configs_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "manager cannot list auth configs" do
    login_as "manager"
    get auth_configs_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "hr cannot list auth configs" do
    login_as "hruser"
    get auth_configs_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot list auth configs" do
    login_as "regular"
    get auth_configs_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "manager cannot view an auth config" do
    login_as "manager"
    get auth_config_path(@target)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "manager cannot reach the new form" do
    login_as "manager"
    get new_auth_config_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "manager cannot create an auth config" do
    login_as "manager"
    assert_no_difference -> { AuthConfig.count } do
      post auth_configs_path, params: { auth_config: valid_attrs }
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "manager cannot update an auth config" do
    login_as "manager"
    patch auth_config_path(@target), params: { auth_config: { name: "Hacked" } }
    assert_redirected_to controller: "dashboard", action: "index"
    assert_equal "Internal", @target.reload.name
  end

  test "manager cannot destroy an auth config" do
    login_as "manager"
    assert_no_difference -> { AuthConfig.count } do
      delete auth_config_path(@target)
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  # ----- admin happy paths -----

  test "admin can list auth configs" do
    login_as "admin"
    get auth_configs_path
    assert_response :success
  end

  test "admin can view an auth config" do
    login_as "admin"
    get auth_config_path(@target)
    assert_response :success
  end

  test "admin can render the new form" do
    login_as "admin"
    get new_auth_config_path
    assert_response :success
  end

  test "admin can render the edit form" do
    login_as "admin"
    get edit_auth_config_path(@target)
    assert_response :success
  end

  test "admin can create an auth config with LDAP fields" do
    login_as "admin"
    assert_difference -> { AuthConfig.count }, 1 do
      post auth_configs_path, params: { auth_config: valid_attrs }
    end
    created = AuthConfig.last
    assert_redirected_to auth_config_path(created)
    # Strong params permit each LDAP-config field — make sure they round-trip.
    assert_equal "ldap.example.com", created.server
    assert_equal 636, created.port
    assert_equal "dc=example,dc=com", created.ldap_base
    assert_equal "EXAMPLE", created.ldap_domain
  end

  test "admin can update an auth config" do
    login_as "admin"
    patch auth_config_path(@target), params: { auth_config: { name: "Renamed" } }
    assert_redirected_to auth_config_path(@target)
    assert_equal "Renamed", @target.reload.name
  end

  test "admin can destroy an auth config" do
    login_as "admin"
    # The fixture is referenced by the user fixtures, so create a fresh row
    # to delete instead of removing the seeded one.
    fresh = AuthConfig.create!(name: "Throwaway", auth_config_type: @internal_type)
    assert_difference -> { AuthConfig.count }, -1 do
      delete auth_config_path(fresh)
    end
    assert_redirected_to auth_configs_path
  end

  test "admin json index returns success" do
    login_as "admin"
    get auth_configs_path(format: :json)
    assert_response :success
  end

  test "admin json show returns success" do
    login_as "admin"
    get auth_config_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    {
      name: "Test LDAP",
      auth_config_type_id: @internal_type.id,
      server: "ldap.example.com",
      port: 636,
      ldap_base: "dc=example,dc=com",
      ldap_domain: "EXAMPLE"
    }
  end
end
