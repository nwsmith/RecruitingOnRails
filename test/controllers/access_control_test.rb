require "test_helper"

class AccessControlTest < ActionDispatch::IntegrationTest
  # Admin-only controllers
  test "admin can access users" do
    login_as "admin"
    get users_path
    assert_response :success
  end

  test "regular user cannot access users" do
    login_as "regular"
    get users_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "admin can access registries" do
    login_as "admin"
    get registries_path
    assert_response :success
  end

  test "regular user cannot access registries" do
    login_as "regular"
    get registries_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "admin can access auth configs" do
    login_as "admin"
    get auth_configs_path
    assert_response :success
  end

  test "regular user cannot access auth configs" do
    login_as "regular"
    get auth_configs_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  # Manager-only controllers
  test "manager can access diary entries" do
    login_as "manager"
    get diary_entries_path
    assert_response :success
  end

  test "regular user cannot access diary entries" do
    login_as "regular"
    get diary_entries_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "admin can access diary entries" do
    login_as "admin"
    get diary_entries_path
    assert_response :success
  end
end
