require 'test_helper'

class PositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = Position.create!(code: 'ENG', name: 'Engineer', description: 'Software engineer')
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  # ----- staff gate: regular user cannot reach any action -----

  test 'unauthenticated index redirects to login' do
    get positions_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list positions' do
    login_as 'regular'
    get positions_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a position' do
    login_as 'regular'
    get position_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_position_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_position_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a position' do
    login_as 'regular'
    assert_no_difference -> { Position.count } do
      post positions_path, params: { position: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a position' do
    login_as 'regular'
    patch position_path(@target), params: { position: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Engineer', @target.reload.name
  end

  test 'regular user cannot destroy a position' do
    login_as 'regular'
    assert_no_difference -> { Position.count } do
      delete position_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  # ----- staff happy paths -----

  test 'admin can list positions' do
    login_as 'admin'
    get positions_path
    assert_response :success
  end

  test 'admin can view a position' do
    login_as 'admin'
    get position_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_position_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_position_path(@target)
    assert_response :success
  end

  test 'admin can create a position' do
    login_as 'admin'
    assert_difference -> { Position.count }, 1 do
      post positions_path, params: { position: valid_attrs }
    end
    assert_redirected_to position_path(Position.last)
  end

  test 'admin can update a position' do
    login_as 'admin'
    patch position_path(@target), params: { position: { name: 'Renamed' } }
    assert_redirected_to position_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy a position' do
    login_as 'admin'
    assert_difference -> { Position.count }, -1 do
      delete position_path(@target)
    end
    assert_redirected_to positions_path
  end

  test 'manager can list positions' do
    login_as 'manager'
    get positions_path
    assert_response :success
  end

  test 'hr can list positions' do
    login_as 'hruser'
    get positions_path
    assert_response :success
  end

  # ----- json -----

  test 'admin json index returns success' do
    login_as 'admin'
    get positions_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get position_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'PM', name: 'Project Manager', description: 'Manages projects' }
  end
end
