require 'test_helper'

class WorkHistoryRowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @candidate = Candidate.create!(
      first_name: 'Jane',
      last_name: 'Doe',
      candidate_status: @status
    )
    @row = WorkHistoryRow.create!(
      candidate: @candidate,
      start_date: 2.years.ago.to_date,
      end_date: 1.year.ago.to_date
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  # ----- baseline auth -----

  test 'unauthenticated index redirects to login' do
    get work_history_rows_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'admin can list work history rows' do
    login_as 'admin'
    get work_history_rows_path
    assert_response :success
  end

  # ----- per-candidate auth gates -----

  test 'regular user cannot list work history rows (staff only)' do
    login_as 'regular'
    get work_history_rows_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view another candidates work history row' do
    login_as 'regular'
    get work_history_row_path(@row)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update another candidates work history row' do
    login_as 'regular'
    patch work_history_row_path(@row),
          params: { work_history_row: { start_date: Date.today } }
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot destroy another candidates work history row' do
    login_as 'regular'
    assert_no_difference -> { WorkHistoryRow.count } do
      delete work_history_row_path(@row)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a work history row for another candidate' do
    login_as 'regular'
    assert_no_difference -> { WorkHistoryRow.count } do
      post work_history_rows_path, params: {
        work_history_row: {
          candidate_id: @candidate.id,
          start_date: Date.today
        }
      }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'self candidate user can view their own pending candidates work history row' do
    self_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @status
    )
    own_row = WorkHistoryRow.create!(
      candidate: self_candidate,
      start_date: 1.year.ago.to_date
    )
    login_as 'self.candidate'
    get work_history_row_path(own_row)
    assert_response :success
  end
end
