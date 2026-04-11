require 'test_helper'

class InterviewTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = InterviewType.create!(code: 'PHONE', name: 'Phone', description: 'Phone screen')
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get interview_types_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list interview types' do
    login_as 'regular'
    get interview_types_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view an interview type' do
    login_as 'regular'
    get interview_type_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_interview_type_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_interview_type_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create an interview type' do
    login_as 'regular'
    assert_no_difference -> { InterviewType.count } do
      post interview_types_path, params: { interview_type: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update an interview type' do
    login_as 'regular'
    patch interview_type_path(@target), params: { interview_type: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Phone', @target.reload.name
  end

  test 'regular user cannot destroy an interview type' do
    login_as 'regular'
    assert_no_difference -> { InterviewType.count } do
      delete interview_type_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list interview types' do
    login_as 'admin'
    get interview_types_path
    assert_response :success
  end

  test 'admin can view an interview type' do
    login_as 'admin'
    get interview_type_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_interview_type_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_interview_type_path(@target)
    assert_response :success
  end

  test 'admin can create an interview type' do
    login_as 'admin'
    assert_difference -> { InterviewType.count }, 1 do
      post interview_types_path, params: { interview_type: valid_attrs }
    end
    assert_redirected_to interview_type_path(InterviewType.last)
  end

  test 'admin can update an interview type' do
    login_as 'admin'
    patch interview_type_path(@target), params: { interview_type: { name: 'Renamed' } }
    assert_redirected_to interview_type_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy an interview type' do
    login_as 'admin'
    assert_difference -> { InterviewType.count }, -1 do
      delete interview_type_path(@target)
    end
    assert_redirected_to interview_types_path
  end

  test 'manager can list interview types' do
    login_as 'manager'
    get interview_types_path
    assert_response :success
  end

  test 'hr can list interview types' do
    login_as 'hruser'
    get interview_types_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get interview_types_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get interview_type_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'TECH', name: 'Technical', description: 'Technical interview' }
  end
end
