require 'test_helper'

class DiaryEntryTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = DiaryEntryType.create!(
      code: 'NOTE', name: 'Note', description: 'Generic note',
      positive: false, negative: false
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get diary_entry_types_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list diary entry types' do
    login_as 'regular'
    get diary_entry_types_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a diary entry type' do
    login_as 'regular'
    get diary_entry_type_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_diary_entry_type_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_diary_entry_type_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a diary entry type' do
    login_as 'regular'
    assert_no_difference -> { DiaryEntryType.count } do
      post diary_entry_types_path, params: { diary_entry_type: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a diary entry type' do
    login_as 'regular'
    patch diary_entry_type_path(@target), params: { diary_entry_type: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Note', @target.reload.name
  end

  test 'regular user cannot destroy a diary entry type' do
    login_as 'regular'
    assert_no_difference -> { DiaryEntryType.count } do
      delete diary_entry_type_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list diary entry types' do
    login_as 'admin'
    get diary_entry_types_path
    assert_response :success
  end

  test 'admin can view a diary entry type' do
    login_as 'admin'
    get diary_entry_type_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_diary_entry_type_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_diary_entry_type_path(@target)
    assert_response :success
  end

  test 'admin can create a diary entry type with positive flag' do
    login_as 'admin'
    assert_difference -> { DiaryEntryType.count }, 1 do
      post diary_entry_types_path, params: { diary_entry_type: valid_attrs }
    end
    created = DiaryEntryType.last
    assert_redirected_to diary_entry_type_path(created)
    assert_equal true, created.positive
    assert_equal false, created.negative
  end

  test 'admin can update positive and negative flags' do
    login_as 'admin'
    patch diary_entry_type_path(@target), params: {
      diary_entry_type: { positive: false, negative: true }
    }
    assert_redirected_to diary_entry_type_path(@target)
    assert_equal false, @target.reload.positive
    assert_equal true, @target.negative
  end

  test 'admin can destroy a diary entry type' do
    login_as 'admin'
    assert_difference -> { DiaryEntryType.count }, -1 do
      delete diary_entry_type_path(@target)
    end
    assert_redirected_to diary_entry_types_path
  end

  test 'manager can list diary entry types' do
    login_as 'manager'
    get diary_entry_types_path
    assert_response :success
  end

  test 'hr can list diary entry types' do
    login_as 'hruser'
    get diary_entry_types_path
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'KUDOS', name: 'Kudos', description: 'Positive feedback', positive: true, negative: false }
  end
end
