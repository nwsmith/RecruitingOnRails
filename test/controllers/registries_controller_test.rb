require "test_helper"

class RegistriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = Registry.create!(key: "test.config.value", value: "original")
  end


  # ----- admin gate: every action requires admin -----

  test "unauthenticated index redirects to login" do
    get registries_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "manager cannot list registries" do
    login_as "manager"
    get registries_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "hr cannot list registries" do
    login_as "hruser"
    get registries_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot list registries" do
    login_as "regular"
    get registries_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "manager cannot view a registry" do
    login_as "manager"
    get registry_path(@target)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "manager cannot create a registry" do
    login_as "manager"
    assert_no_difference -> { Registry.count } do
      post registries_path, params: { registry: valid_attrs }
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "manager cannot update a registry" do
    login_as "manager"
    patch registry_path(@target), params: { registry: { value: "hacked" } }
    assert_redirected_to controller: "dashboard", action: "index"
    assert_equal "original", @target.reload.value
  end

  test "manager cannot destroy a registry" do
    login_as "manager"
    assert_no_difference -> { Registry.count } do
      delete registry_path(@target)
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  # ----- admin happy paths -----

  test "admin can list registries" do
    login_as "admin"
    get registries_path
    assert_response :success
  end

  test "admin can view a registry" do
    login_as "admin"
    get registry_path(@target)
    assert_response :success
  end

  test "admin can render the new form" do
    login_as "admin"
    get new_registry_path
    assert_response :success
  end

  test "admin can render the edit form" do
    login_as "admin"
    get edit_registry_path(@target)
    assert_response :success
  end

  test "admin can create a registry with key/value" do
    login_as "admin"
    assert_difference -> { Registry.count }, 1 do
      post registries_path, params: { registry: valid_attrs }
    end
    created = Registry.last
    assert_redirected_to registry_path(created)
    assert_equal "feature.flag.enabled", created.key
    assert_equal "true", created.value
  end

  test "admin can update the value of a registry" do
    login_as "admin"
    patch registry_path(@target), params: { registry: { value: "updated" } }
    assert_redirected_to registry_path(@target)
    assert_equal "updated", @target.reload.value
  end

  test "admin can destroy a registry" do
    login_as "admin"
    assert_difference -> { Registry.count }, -1 do
      delete registry_path(@target)
    end
    assert_redirected_to registries_path
  end

  test "admin json index returns success" do
    login_as "admin"
    get registries_path(format: :json)
    assert_response :success
  end

  test "admin json show returns success" do
    login_as "admin"
    get registry_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { key: "feature.flag.enabled", value: "true" }
  end
end
