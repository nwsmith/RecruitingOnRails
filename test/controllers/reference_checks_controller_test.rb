require 'test_helper'

class ReferenceChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @candidate = Candidate.create!(
      first_name: 'Jane',
      last_name: 'Doe',
      candidate_status: @status
    )
    @reference = ReferenceCheck.create!(
      candidate: @candidate,
      name: 'Bob Manager',
      title: 'EM',
      company: 'Acme',
      notes: 'Strong hire'
    )
  end


  # ----- baseline auth -----

  test 'unauthenticated index redirects to login' do
    get reference_checks_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'admin can list references' do
    login_as 'admin'
    get reference_checks_path
    assert_response :success
  end

  test 'manager can list references' do
    login_as 'manager'
    get reference_checks_path
    assert_response :success
  end

  test 'hr can list references' do
    login_as 'hruser'
    get reference_checks_path
    assert_response :success
  end

  # ----- reference checks are staff-only EVEN for the candidate themselves -----
  #
  # Reference feedback can be sensitive (e.g. "do not hire" signals from past
  # managers), so the candidate should not see what their references said.
  # Verify that even the self.candidate user is denied across the board.

  test 'regular user cannot list references' do
    login_as 'regular'
    get reference_checks_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a reference' do
    login_as 'regular'
    get reference_check_path(@reference)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a reference' do
    login_as 'regular'
    assert_no_difference -> { ReferenceCheck.count } do
      post reference_checks_path, params: {
        reference_check: { candidate_id: @candidate.id, name: 'X' }
      }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot destroy a reference' do
    login_as 'regular'
    assert_no_difference -> { ReferenceCheck.count } do
      delete reference_check_path(@reference)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'self candidate user cannot view references about themselves' do
    self_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @status
    )
    own_ref = ReferenceCheck.create!(
      candidate: self_candidate,
      name: 'Carol Manager',
      notes: 'Confidential'
    )
    login_as 'self.candidate'
    get reference_check_path(own_ref)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end
end
