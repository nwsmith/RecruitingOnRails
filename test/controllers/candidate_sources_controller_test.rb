require 'test_helper'

class CandidateSourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target = CandidateSource.create!(code: 'WEB', name: 'Website', description: 'Online application')
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  test 'unauthenticated index redirects to login' do
    get candidate_sources_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'regular user cannot list candidate sources' do
    login_as 'regular'
    get candidate_sources_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a candidate source' do
    login_as 'regular'
    get candidate_source_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the new form' do
    login_as 'regular'
    get new_candidate_source_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot reach the edit form' do
    login_as 'regular'
    get edit_candidate_source_path(@target)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a candidate source' do
    login_as 'regular'
    assert_no_difference -> { CandidateSource.count } do
      post candidate_sources_path, params: { candidate_source: valid_attrs }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update a candidate source' do
    login_as 'regular'
    patch candidate_source_path(@target), params: { candidate_source: { name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Website', @target.reload.name
  end

  test 'regular user cannot destroy a candidate source' do
    login_as 'regular'
    assert_no_difference -> { CandidateSource.count } do
      delete candidate_source_path(@target)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can list candidate sources' do
    login_as 'admin'
    get candidate_sources_path
    assert_response :success
  end

  test 'admin can view a candidate source' do
    login_as 'admin'
    get candidate_source_path(@target)
    assert_response :success
  end

  test 'admin can render the new form' do
    login_as 'admin'
    get new_candidate_source_path
    assert_response :success
  end

  test 'admin can render the edit form' do
    login_as 'admin'
    get edit_candidate_source_path(@target)
    assert_response :success
  end

  test 'admin can create a candidate source' do
    login_as 'admin'
    assert_difference -> { CandidateSource.count }, 1 do
      post candidate_sources_path, params: { candidate_source: valid_attrs }
    end
    assert_redirected_to candidate_source_path(CandidateSource.last)
  end

  test 'admin can update a candidate source' do
    login_as 'admin'
    patch candidate_source_path(@target), params: { candidate_source: { name: 'Renamed' } }
    assert_redirected_to candidate_source_path(@target)
    assert_equal 'Renamed', @target.reload.name
  end

  test 'admin can destroy a candidate source' do
    login_as 'admin'
    assert_difference -> { CandidateSource.count }, -1 do
      delete candidate_source_path(@target)
    end
    assert_redirected_to candidate_sources_path
  end

  test 'manager can list candidate sources' do
    login_as 'manager'
    get candidate_sources_path
    assert_response :success
  end

  test 'hr can list candidate sources' do
    login_as 'hruser'
    get candidate_sources_path
    assert_response :success
  end

  test 'admin json index returns success' do
    login_as 'admin'
    get candidate_sources_path(format: :json)
    assert_response :success
  end

  test 'admin json show returns success' do
    login_as 'admin'
    get candidate_source_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    { code: 'REF', name: 'Referral', description: 'Employee referral' }
  end
end
