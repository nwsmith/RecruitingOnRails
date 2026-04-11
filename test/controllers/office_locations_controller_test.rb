require "test_helper"

class OfficeLocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = OfficeLocation.create!(code: "YYC", name: "Calgary", description: "Calgary office")
  end


  test "unauthenticated index redirects to login" do
    get office_locations_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "regular user cannot list office locations" do
    login_as "regular"
    get office_locations_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot view an office location" do
    login_as "regular"
    get office_location_path(@target)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot reach the new form" do
    login_as "regular"
    get new_office_location_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot reach the edit form" do
    login_as "regular"
    get edit_office_location_path(@target)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot create an office location" do
    login_as "regular"
    assert_no_difference -> { OfficeLocation.count } do
      post office_locations_path, params: { office_location: valid_attrs }
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot update an office location" do
    login_as "regular"
    patch office_location_path(@target), params: { office_location: { name: "Hacked" } }
    assert_redirected_to controller: "dashboard", action: "index"
    assert_equal "Calgary", @target.reload.name
  end

  test "regular user cannot destroy an office location" do
    login_as "regular"
    assert_no_difference -> { OfficeLocation.count } do
      delete office_location_path(@target)
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "admin can list office locations" do
    login_as "admin"
    get office_locations_path
    assert_response :success
  end

  test "admin can view an office location" do
    login_as "admin"
    get office_location_path(@target)
    assert_response :success
  end

  test "admin can render the new form" do
    login_as "admin"
    get new_office_location_path
    assert_response :success
  end

  test "admin can render the edit form" do
    login_as "admin"
    get edit_office_location_path(@target)
    assert_response :success
  end

  test "admin can create an office location" do
    login_as "admin"
    assert_difference -> { OfficeLocation.count }, 1 do
      post office_locations_path, params: { office_location: valid_attrs }
    end
    assert_redirected_to office_location_path(OfficeLocation.last)
  end

  test "admin can update an office location" do
    login_as "admin"
    patch office_location_path(@target), params: { office_location: { name: "Renamed" } }
    assert_redirected_to office_location_path(@target)
    assert_equal "Renamed", @target.reload.name
  end

  test "admin can destroy an office location" do
    login_as "admin"
    assert_difference -> { OfficeLocation.count }, -1 do
      delete office_location_path(@target)
    end
    assert_redirected_to office_locations_path
  end

  test "manager can list office locations" do
    login_as "manager"
    get office_locations_path
    assert_response :success
  end

  test "hr can list office locations" do
    login_as "hruser"
    get office_locations_path
    assert_response :success
  end

  test "admin json index returns success" do
    login_as "admin"
    get office_locations_path(format: :json)
    assert_response :success
  end

  test "admin json show returns success" do
    login_as "admin"
    get office_location_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: "YYZ", name: "Toronto", description: "Toronto office" }
  end
end
