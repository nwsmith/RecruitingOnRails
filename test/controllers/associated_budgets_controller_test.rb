require 'test_helper'

class AssociatedBudgetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = AssociatedBudget.create!(
      code: 'ENG24', name: 'Engineering 2024', description: 'Engineering headcount budget',
      active: true
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get associated_budgets_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list associated budgets' do
    login_as 'regular'
    get associated_budgets_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view an associated budget' do
    login_as 'regular'
    get associated_budget_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_associated_budget_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_associated_budget_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create an associated budget' do
    login_as 'regular'
    assert_no_difference -> { AssociatedBudget.count } do
      post associated_budgets_path, params: { associated_budget: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update an associated budget' do
    login_as 'regular'
    patch associated_budget_path(@target), params: { associated_budget: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Engineering 2024', @target.reload.name
  end

  test 'regular user cannot destroy an associated budget' do
    login_as 'regular'
    assert_no_difference -> { AssociatedBudget.count } do
      delete associated_budget_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list associated budgets' do
    login_as 'admin'
    get associated_budgets_path
    assert_response :success
  end

  test 'admin can view an associated budget' do
    login_as 'admin'
    get associated_budget_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_associated_budget_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_associated_budget_path(@target)
    assert_response :success
  end

  test 'admin can create an associated budget' do
    login_as 'admin'
    assert_difference -> { AssociatedBudget.count }, 1 do
      post associated_budgets_path, params: { associated_budget: valid_attrs }
    end
    created = AssociatedBudget.last
    assert_redirected_to associated_budget_path(created)
    assert_equal true, created.active
  end

  test 'admin can update an associated budget and flip active' do
    login_as 'admin'
    patch associated_budget_path(@target), params: {
      associated_budget: { name: 'Renamed', active: false }
    }
    assert_redirected_to associated_budget_path(@target)
    assert_equal 'Renamed', @target.reload.name
    assert_equal false, @target.active
  end

  test 'admin can destroy an associated budget' do
    login_as 'admin'
    assert_difference -> { AssociatedBudget.count }, -1 do
      delete associated_budget_path(@target)
    end
    assert_redirected_to associated_budgets_path
  end

  test 'manager can list associated budgets' do
    login_as 'manager'
    get associated_budgets_path
    assert_response :success
  end

  test 'hr can list associated budgets' do
    login_as 'hruser'
    get associated_budgets_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get associated_budgets_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get associated_budget_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'OPS24', name: 'Operations 2024', description: 'Ops headcount', active: true }
  end
end
