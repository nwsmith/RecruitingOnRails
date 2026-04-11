require "test_helper"

class BudgetingTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = BudgetingType.create!(code: "OPEX", name: "Operating", description: "Operating expenses")
  end


  test "unauthenticated index redirects to login" do
    get budgeting_types_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "regular user cannot list budgeting types" do
    login_as "regular"
    get budgeting_types_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot view a budgeting type" do
    login_as "regular"
    get budgeting_type_path(@target)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot reach the new form" do
    login_as "regular"
    get new_budgeting_type_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot reach the edit form" do
    login_as "regular"
    get edit_budgeting_type_path(@target)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot create a budgeting type" do
    login_as "regular"
    assert_no_difference -> { BudgetingType.count } do
      post budgeting_types_path, params: { budgeting_type: valid_attrs }
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot update a budgeting type" do
    login_as "regular"
    patch budgeting_type_path(@target), params: { budgeting_type: { name: "Hacked" } }
    assert_redirected_to controller: "dashboard", action: "index"
    assert_equal "Operating", @target.reload.name
  end

  test "regular user cannot destroy a budgeting type" do
    login_as "regular"
    assert_no_difference -> { BudgetingType.count } do
      delete budgeting_type_path(@target)
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "admin can list budgeting types" do
    login_as "admin"
    get budgeting_types_path
    assert_response :success
  end

  test "admin can view a budgeting type" do
    login_as "admin"
    get budgeting_type_path(@target)
    assert_response :success
  end

  test "admin can render the new form" do
    login_as "admin"
    get new_budgeting_type_path
    assert_response :success
  end

  test "admin can render the edit form" do
    login_as "admin"
    get edit_budgeting_type_path(@target)
    assert_response :success
  end

  test "admin can create a budgeting type" do
    login_as "admin"
    assert_difference -> { BudgetingType.count }, 1 do
      post budgeting_types_path, params: { budgeting_type: valid_attrs }
    end
    assert_redirected_to budgeting_type_path(BudgetingType.last)
  end

  test "admin can update a budgeting type" do
    login_as "admin"
    patch budgeting_type_path(@target), params: { budgeting_type: { name: "Renamed" } }
    assert_redirected_to budgeting_type_path(@target)
    assert_equal "Renamed", @target.reload.name
  end

  test "admin can destroy a budgeting type" do
    login_as "admin"
    assert_difference -> { BudgetingType.count }, -1 do
      delete budgeting_type_path(@target)
    end
    assert_redirected_to budgeting_types_path
  end

  test "manager can list budgeting types" do
    login_as "manager"
    get budgeting_types_path
    assert_response :success
  end

  test "hr can list budgeting types" do
    login_as "hruser"
    get budgeting_types_path
    assert_response :success
  end

  test "admin json index returns success" do
    login_as "admin"
    get budgeting_types_path(format: :json)
    assert_response :success
  end

  test "admin json show returns success" do
    login_as "admin"
    get budgeting_type_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: "CAPEX", name: "Capital", description: "Capital expenses" }
  end
end
