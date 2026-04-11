require 'test_helper'

class CandidateStatusesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = CandidateStatus.create!(code: 'PEND', name: 'Pending', description: 'Pending review')
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get candidate_statuses_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list candidate statuses' do
    login_as 'regular'
    get candidate_statuses_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a candidate status' do
    login_as 'regular'
    get candidate_status_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_candidate_status_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_candidate_status_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a candidate status' do
    login_as 'regular'
    assert_no_difference -> { CandidateStatus.count } do
      post candidate_statuses_path, params: { candidate_status: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a candidate status' do
    login_as 'regular'
    patch candidate_status_path(@target), params: { candidate_status: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Pending', @target.reload.name
  end

  test 'regular user cannot destroy a candidate status' do
    login_as 'regular'
    assert_no_difference -> { CandidateStatus.count } do
      delete candidate_status_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list candidate statuses' do
    login_as 'admin'
    get candidate_statuses_path
    assert_response :success
  end

  test 'admin can view a candidate status' do
    login_as 'admin'
    get candidate_status_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_candidate_status_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_candidate_status_path(@target)
    assert_response :success
  end

  test 'admin can create a candidate status' do
    login_as 'admin'
    assert_difference -> { CandidateStatus.count }, 1 do
      post candidate_statuses_path, params: { candidate_status: valid_attrs }
    end
    assert_redirected_to candidate_status_path(CandidateStatus.last)
  end

  test 'admin can update a candidate status' do
    login_as 'admin'
    patch candidate_status_path(@target), params: { candidate_status: { name: 'Renamed' } }
    assert_redirected_to candidate_status_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy a candidate status' do
    login_as 'admin'
    assert_difference -> { CandidateStatus.count }, -1 do
      delete candidate_status_path(@target)
    end
    assert_redirected_to candidate_statuses_path
  end

  test 'manager can list candidate statuses' do
    login_as 'manager'
    get candidate_statuses_path
    assert_response :success
  end

  test 'hr can list candidate statuses' do
    login_as 'hruser'
    get candidate_statuses_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get candidate_statuses_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get candidate_status_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'HIRED', name: 'Hired', description: 'Hired and onboarded' }
  end
end
