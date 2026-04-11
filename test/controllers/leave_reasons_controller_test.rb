require 'test_helper'

class LeaveReasonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = LeaveReason.create!(code: 'COMP', name: 'Compensation', description: 'Better compensation')
  end


  test 'unauthenticated index redirects to login' do
    get leave_reasons_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list leave reasons' do
    login_as 'regular'
    get leave_reasons_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a leave reason' do
    login_as 'regular'
    get leave_reason_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_leave_reason_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_leave_reason_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a leave reason' do
    login_as 'regular'
    assert_no_difference -> { LeaveReason.count } do
      post leave_reasons_path, params: { leave_reason: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a leave reason' do
    login_as 'regular'
    patch leave_reason_path(@target), params: { leave_reason: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Compensation', @target.reload.name
  end

  test 'regular user cannot destroy a leave reason' do
    login_as 'regular'
    assert_no_difference -> { LeaveReason.count } do
      delete leave_reason_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list leave reasons' do
    login_as 'admin'
    get leave_reasons_path
    assert_response :success
  end

  test 'admin can view a leave reason' do
    login_as 'admin'
    get leave_reason_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_leave_reason_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_leave_reason_path(@target)
    assert_response :success
  end

  test 'admin can create a leave reason' do
    login_as 'admin'
    assert_difference -> { LeaveReason.count }, 1 do
      post leave_reasons_path, params: { leave_reason: valid_attrs }
    end
    assert_redirected_to leave_reason_path(LeaveReason.last)
  end

  test 'admin can update a leave reason' do
    login_as 'admin'
    patch leave_reason_path(@target), params: { leave_reason: { name: 'Renamed' } }
    assert_redirected_to leave_reason_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy a leave reason' do
    login_as 'admin'
    assert_difference -> { LeaveReason.count }, -1 do
      delete leave_reason_path(@target)
    end
    assert_redirected_to leave_reasons_path
  end

  test 'manager can list leave reasons' do
    login_as 'manager'
    get leave_reasons_path
    assert_response :success
  end

  test 'hr can list leave reasons' do
    login_as 'hruser'
    get leave_reasons_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get leave_reasons_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get leave_reason_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'COMM', name: 'Commute', description: 'Long commute' }
  end
end
