require 'test_helper'

class CodeProblemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = CodeProblem.create!(code: 'FIZZ', name: 'FizzBuzz', description: 'Classic FizzBuzz')
  end


  test 'unauthenticated index redirects to login' do
    get code_problems_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list code problems' do
    login_as 'regular'
    get code_problems_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a code problem' do
    login_as 'regular'
    get code_problem_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_code_problem_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_code_problem_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a code problem' do
    login_as 'regular'
    assert_no_difference -> { CodeProblem.count } do
      post code_problems_path, params: { code_problem: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a code problem' do
    login_as 'regular'
    patch code_problem_path(@target), params: { code_problem: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'FizzBuzz', @target.reload.name
  end

  test 'regular user cannot destroy a code problem' do
    login_as 'regular'
    assert_no_difference -> { CodeProblem.count } do
      delete code_problem_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list code problems' do
    login_as 'admin'
    get code_problems_path
    assert_response :success
  end

  test 'admin can view a code problem' do
    login_as 'admin'
    get code_problem_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_code_problem_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_code_problem_path(@target)
    assert_response :success
  end

  test 'admin can create a code problem' do
    login_as 'admin'
    assert_difference -> { CodeProblem.count }, 1 do
      post code_problems_path, params: { code_problem: valid_attrs }
    end
    assert_redirected_to code_problem_path(CodeProblem.last)
  end

  test 'admin can update a code problem' do
    login_as 'admin'
    patch code_problem_path(@target), params: { code_problem: { name: 'Renamed' } }
    assert_redirected_to code_problem_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy a code problem' do
    login_as 'admin'
    assert_difference -> { CodeProblem.count }, -1 do
      delete code_problem_path(@target)
    end
    assert_redirected_to code_problems_path
  end

  test 'manager can list code problems' do
    login_as 'manager'
    get code_problems_path
    assert_response :success
  end

  test 'hr can list code problems' do
    login_as 'hruser'
    get code_problems_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get code_problems_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get code_problem_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'PALIN', name: 'Palindrome Check', description: 'Detect palindromes' }
  end
end
