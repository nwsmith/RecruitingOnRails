require 'test_helper'

class GendersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = Gender.create!(code: 'F', name: 'Female', description: 'Female')
  end


  test 'unauthenticated index redirects to login' do
    get genders_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list genders' do
    login_as 'regular'
    get genders_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a gender' do
    login_as 'regular'
    get gender_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_gender_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_gender_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a gender' do
    login_as 'regular'
    assert_no_difference -> { Gender.count } do
      post genders_path, params: { gender: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a gender' do
    login_as 'regular'
    patch gender_path(@target), params: { gender: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Female', @target.reload.name
  end

  test 'regular user cannot destroy a gender' do
    login_as 'regular'
    assert_no_difference -> { Gender.count } do
      delete gender_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list genders' do
    login_as 'admin'
    get genders_path
    assert_response :success
  end

  test 'admin can view a gender' do
    login_as 'admin'
    get gender_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_gender_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_gender_path(@target)
    assert_response :success
  end

  test 'admin can create a gender' do
    login_as 'admin'
    assert_difference -> { Gender.count }, 1 do
      post genders_path, params: { gender: valid_attrs }
    end
    assert_redirected_to gender_path(Gender.last)
  end

  test 'admin can update a gender' do
    login_as 'admin'
    patch gender_path(@target), params: { gender: { name: 'Renamed' } }
    assert_redirected_to gender_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy a gender' do
    login_as 'admin'
    assert_difference -> { Gender.count }, -1 do
      delete gender_path(@target)
    end
    assert_redirected_to genders_path
  end

  test 'manager can list genders' do
    login_as 'manager'
    get genders_path
    assert_response :success
  end

  test 'hr can list genders' do
    login_as 'hruser'
    get genders_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get genders_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get gender_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'M', name: 'Male', description: 'Male' }
  end
end
