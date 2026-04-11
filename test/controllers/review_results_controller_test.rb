require 'test_helper'

class ReviewResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = ReviewResult.create!(
      code: 'PASS', name: 'Pass', description: 'Passed the bar',
      is_approval: true, is_disapproval: false
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get review_results_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list review results' do
    login_as 'regular'
    get review_results_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a review result' do
    login_as 'regular'
    get review_result_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_review_result_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_review_result_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a review result' do
    login_as 'regular'
    assert_no_difference -> { ReviewResult.count } do
      post review_results_path, params: { review_result: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a review result' do
    login_as 'regular'
    patch review_result_path(@target), params: { review_result: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Pass', @target.reload.name
  end

  test 'regular user cannot destroy a review result' do
    login_as 'regular'
    assert_no_difference -> { ReviewResult.count } do
      delete review_result_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list review results' do
    login_as 'admin'
    get review_results_path
    assert_response :success
  end

  test 'admin can view a review result' do
    login_as 'admin'
    get review_result_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_review_result_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_review_result_path(@target)
    assert_response :success
  end

  test 'admin can create a review result with disapproval flag' do
    login_as 'admin'
    assert_difference -> { ReviewResult.count }, 1 do
      post review_results_path, params: { review_result: valid_attrs }
    end
    created = ReviewResult.last
    assert_redirected_to review_result_path(created)
    assert_equal false, created.is_approval
    assert_equal true, created.is_disapproval
  end

  test 'admin can flip approval flags' do
    login_as 'admin'
    patch review_result_path(@target), params: {
      review_result: { is_approval: false, is_disapproval: true }
    }
    assert_redirected_to review_result_path(@target)
    assert_equal false, @target.reload.is_approval
    assert_equal true, @target.is_disapproval
  end

  test 'admin can destroy a review result' do
    login_as 'admin'
    assert_difference -> { ReviewResult.count }, -1 do
      delete review_result_path(@target)
    end
    assert_redirected_to review_results_path
  end

  test 'manager can list review results' do
    login_as 'manager'
    get review_results_path
    assert_response :success
  end

  test 'hr can list review results' do
    login_as 'hruser'
    get review_results_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get review_results_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get review_result_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'FAIL', name: 'Fail', description: 'Did not pass', is_approval: false, is_disapproval: true }
  end
end
