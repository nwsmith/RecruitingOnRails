require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = Group.create!(name: 'Engineering', active: true)
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get groups_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list groups' do
    login_as 'regular'
    get groups_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a group' do
    login_as 'regular'
    get group_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_group_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_group_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a group' do
    login_as 'regular'
    assert_no_difference -> { Group.count } do
      post groups_path, params: { group: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a group' do
    login_as 'regular'
    patch group_path(@target), params: { group: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Engineering', @target.reload.name
  end

  test 'regular user cannot destroy a group' do
    login_as 'regular'
    assert_no_difference -> { Group.count } do
      delete group_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list groups' do
    login_as 'admin'
    get groups_path
    assert_response :success
  end

  test 'admin can view a group' do
    login_as 'admin'
    get group_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_group_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_group_path(@target)
    assert_response :success
  end

  test 'admin can create a group with name and active' do
    login_as 'admin'
    assert_difference -> { Group.count }, 1 do
      post groups_path, params: { group: valid_attrs }
    end
    created = Group.last
    assert_redirected_to group_path(created)
    assert_equal 'Sales', created.name
    assert_equal true, created.active
  end

  test 'admin can toggle active' do
    login_as 'admin'
    patch group_path(@target), params: { group: { active: false } }
    assert_redirected_to group_path(@target)
    assert_equal false, @target.reload.active
  end

  test 'admin can destroy a group' do
    login_as 'admin'
    assert_difference -> { Group.count }, -1 do
      delete group_path(@target)
    end
    assert_redirected_to groups_path
  end

  test 'manager can list groups' do
    login_as 'manager'
    get groups_path
    assert_response :success
  end

  test 'hr can list groups' do
    login_as 'hruser'
    get groups_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get groups_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get group_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { name: 'Sales', active: true }
  end
end
