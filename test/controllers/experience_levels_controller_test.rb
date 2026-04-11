require 'test_helper'

class ExperienceLevelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = ExperienceLevel.create!(code: 'JR', name: 'Junior', description: 'Junior level', color: '#aabbcc')
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get experience_levels_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list experience levels' do
    login_as 'regular'
    get experience_levels_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view an experience level' do
    login_as 'regular'
    get experience_level_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_experience_level_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_experience_level_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create an experience level' do
    login_as 'regular'
    assert_no_difference -> { ExperienceLevel.count } do
      post experience_levels_path, params: { experience_level: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update an experience level' do
    login_as 'regular'
    patch experience_level_path(@target), params: { experience_level: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Junior', @target.reload.name
  end

  test 'regular user cannot destroy an experience level' do
    login_as 'regular'
    assert_no_difference -> { ExperienceLevel.count } do
      delete experience_level_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list experience levels' do
    login_as 'admin'
    get experience_levels_path
    assert_response :success
  end

  test 'admin can view an experience level' do
    login_as 'admin'
    get experience_level_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_experience_level_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_experience_level_path(@target)
    assert_response :success
  end

  test 'admin can create an experience level with a color' do
    login_as 'admin'
    assert_difference -> { ExperienceLevel.count }, 1 do
      post experience_levels_path, params: { experience_level: valid_attrs }
    end
    created = ExperienceLevel.last
    assert_redirected_to experience_level_path(created)
    # The color attribute is permitted via strong params and should round-trip.
    assert_equal '#112233', created.color
  end

  test 'admin can update an experience level color' do
    login_as 'admin'
    patch experience_level_path(@target), params: { experience_level: { color: '#ddeeff' } }
    assert_redirected_to experience_level_path(@target)
    assert_equal '#ddeeff', @target.reload.color
  end

  test 'admin can destroy an experience level' do
    login_as 'admin'
    assert_difference -> { ExperienceLevel.count }, -1 do
      delete experience_level_path(@target)
    end
    assert_redirected_to experience_levels_path
  end

  test 'manager can list experience levels' do
    login_as 'manager'
    get experience_levels_path
    assert_response :success
  end

  test 'hr can list experience levels' do
    login_as 'hruser'
    get experience_levels_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get experience_levels_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get experience_level_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'SR', name: 'Senior', description: 'Senior level', color: '#112233' }
  end
end
