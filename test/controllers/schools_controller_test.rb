require "test_helper"

class SchoolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = School.create!(code: "UCAL", name: "University of Calgary", description: "UCalgary")
  end


  test "unauthenticated index redirects to login" do
    get schools_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "regular user cannot list schools" do
    login_as "regular"
    get schools_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot view a school" do
    login_as "regular"
    get school_path(@target)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot reach the new form" do
    login_as "regular"
    get new_school_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot reach the edit form" do
    login_as "regular"
    get edit_school_path(@target)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot create a school" do
    login_as "regular"
    assert_no_difference -> { School.count } do
      post schools_path, params: { school: valid_attrs }
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot update a school" do
    login_as "regular"
    patch school_path(@target), params: { school: { name: "Hacked" } }
    assert_redirected_to controller: "dashboard", action: "index"
    assert_equal "University of Calgary", @target.reload.name
  end

  test "regular user cannot destroy a school" do
    login_as "regular"
    assert_no_difference -> { School.count } do
      delete school_path(@target)
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "admin can list schools" do
    login_as "admin"
    get schools_path
    assert_response :success
  end

  test "admin can view a school" do
    login_as "admin"
    get school_path(@target)
    assert_response :success
  end

  test "admin can render the new form" do
    login_as "admin"
    get new_school_path
    assert_response :success
  end

  test "admin can render the edit form" do
    login_as "admin"
    get edit_school_path(@target)
    assert_response :success
  end

  test "admin can create a school" do
    login_as "admin"
    assert_difference -> { School.count }, 1 do
      post schools_path, params: { school: valid_attrs }
    end
    assert_redirected_to school_path(School.last)
  end

  test "admin can update a school" do
    login_as "admin"
    patch school_path(@target), params: { school: { name: "Renamed" } }
    assert_redirected_to school_path(@target)
    assert_equal "Renamed", @target.reload.name
  end

  test "admin can destroy a school" do
    login_as "admin"
    assert_difference -> { School.count }, -1 do
      delete school_path(@target)
    end
    assert_redirected_to schools_path
  end

  test "manager can list schools" do
    login_as "manager"
    get schools_path
    assert_response :success
  end

  test "hr can list schools" do
    login_as "hruser"
    get schools_path
    assert_response :success
  end

  test "admin json index returns success" do
    login_as "admin"
    get schools_path(format: :json)
    assert_response :success
  end

  test "admin json show returns success" do
    login_as "admin"
    get school_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: "UBC", name: "University of British Columbia", description: "UBC" }
  end
end
