require 'test_helper'

class PreviousEmployersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = PreviousEmployer.create!(code: 'ACME', name: 'Acme Corp', description: 'Acme Corporation')
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get previous_employers_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list previous employers' do
    login_as 'regular'
    get previous_employers_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a previous employer' do
    login_as 'regular'
    get previous_employer_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_previous_employer_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_previous_employer_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a previous employer' do
    login_as 'regular'
    assert_no_difference -> { PreviousEmployer.count } do
      post previous_employers_path, params: { previous_employer: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a previous employer' do
    login_as 'regular'
    patch previous_employer_path(@target), params: { previous_employer: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Acme Corp', @target.reload.name
  end

  test 'regular user cannot destroy a previous employer' do
    login_as 'regular'
    assert_no_difference -> { PreviousEmployer.count } do
      delete previous_employer_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list previous employers' do
    login_as 'admin'
    get previous_employers_path
    assert_response :success
  end

  test 'admin can view a previous employer' do
    login_as 'admin'
    get previous_employer_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_previous_employer_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_previous_employer_path(@target)
    assert_response :success
  end

  test 'admin can create a previous employer' do
    login_as 'admin'
    assert_difference -> { PreviousEmployer.count }, 1 do
      post previous_employers_path, params: { previous_employer: valid_attrs }
    end
    assert_redirected_to previous_employer_path(PreviousEmployer.last)
  end

  test 'admin can update a previous employer' do
    login_as 'admin'
    patch previous_employer_path(@target), params: { previous_employer: { name: 'Renamed' } }
    assert_redirected_to previous_employer_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy a previous employer' do
    login_as 'admin'
    assert_difference -> { PreviousEmployer.count }, -1 do
      delete previous_employer_path(@target)
    end
    assert_redirected_to previous_employers_path
  end

  test 'manager can list previous employers' do
    login_as 'manager'
    get previous_employers_path
    assert_response :success
  end

  test 'hr can list previous employers' do
    login_as 'hruser'
    get previous_employers_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get previous_employers_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get previous_employer_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'INIT', name: 'Initech', description: 'Initech Inc' }
  end
end
