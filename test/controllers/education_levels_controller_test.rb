require 'test_helper'

class EducationLevelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = EducationLevel.create!(code: 'BS', name: 'Bachelor', description: 'Bachelor degree')
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get education_levels_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list education levels' do
    login_as 'regular'
    get education_levels_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view an education level' do
    login_as 'regular'
    get education_level_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_education_level_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_education_level_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create an education level' do
    login_as 'regular'
    assert_no_difference -> { EducationLevel.count } do
      post education_levels_path, params: { education_level: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update an education level' do
    login_as 'regular'
    patch education_level_path(@target), params: { education_level: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Bachelor', @target.reload.name
  end

  test 'regular user cannot destroy an education level' do
    login_as 'regular'
    assert_no_difference -> { EducationLevel.count } do
      delete education_level_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list education levels' do
    login_as 'admin'
    get education_levels_path
    assert_response :success
  end

  test 'admin can view an education level' do
    login_as 'admin'
    get education_level_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_education_level_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_education_level_path(@target)
    assert_response :success
  end

  test 'admin can create an education level' do
    login_as 'admin'
    assert_difference -> { EducationLevel.count }, 1 do
      post education_levels_path, params: { education_level: valid_attrs }
    end
    assert_redirected_to education_level_path(EducationLevel.last)
  end

  test 'admin can update an education level' do
    login_as 'admin'
    patch education_level_path(@target), params: { education_level: { name: 'Renamed' } }
    assert_redirected_to education_level_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy an education level' do
    login_as 'admin'
    assert_difference -> { EducationLevel.count }, -1 do
      delete education_level_path(@target)
    end
    assert_redirected_to education_levels_path
  end

  test 'manager can list education levels' do
    login_as 'manager'
    get education_levels_path
    assert_response :success
  end

  test 'hr can list education levels' do
    login_as 'hruser'
    get education_levels_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get education_levels_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get education_level_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'MS', name: 'Master', description: 'Master degree' }
  end
end
