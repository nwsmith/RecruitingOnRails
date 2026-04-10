require 'test_helper'

class CandidatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pending_status = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @hired_status   = CandidateStatus.create!(code: 'HIRED', name: 'Hired')

    # The self_candidate_user fixture is named "Self Candidate" so that
    # Candidate#username ("self.candidate") matches its user_name. The auth
    # rule allows a user to view their own application while it's pending.
    @self_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @pending_status
    )

    @other_candidate = Candidate.create!(
      first_name: 'Someone',
      last_name: 'Else',
      candidate_status: @hired_status
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  # ----- show: privileged users -----

  test 'admin can view any candidate' do
    login_as 'admin'
    get candidate_path(@other_candidate)
    assert_response :success
  end

  test 'manager can view any candidate' do
    login_as 'manager'
    get candidate_path(@other_candidate)
    assert_response :success
  end

  test 'hr can view any candidate' do
    login_as 'hruser'
    get candidate_path(@other_candidate)
    assert_response :success
  end

  # ----- show: regression tests for the auth bypass fix -----

  test 'regular user cannot view another candidate via show' do
    login_as 'regular'
    get candidate_path(@other_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'user can view their own candidate while pending' do
    login_as 'self.candidate'
    get candidate_path(@self_candidate)
    assert_response :success
  end

  test 'user cannot view their own candidate after hire' do
    login_as 'self.candidate'
    @self_candidate.update_column(:candidate_status_id, @hired_status.id)
    get candidate_path(@self_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'user cannot view someone else even with matching pending status' do
    login_as 'self.candidate'
    get candidate_path(@other_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  # ----- edit / update / destroy: must enforce the same rule -----

  test 'regular user cannot edit another candidate' do
    login_as 'regular'
    get edit_candidate_path(@other_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update another candidate' do
    login_as 'regular'
    patch candidate_path(@other_candidate), params: { candidate: { first_name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Someone', @other_candidate.reload.first_name
  end

  test 'regular user cannot destroy another candidate' do
    login_as 'regular'
    assert_no_difference -> { Candidate.count } do
      delete candidate_path(@other_candidate)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  # ----- output safety -----

  test 'show escapes html in candidate name' do
    xss = Candidate.create!(
      first_name: '<script>alert(1)</script>',
      last_name: 'Doe',
      candidate_status: @hired_status
    )
    login_as 'admin'
    get candidate_path(xss)
    assert_response :success
    assert_no_match '<script>alert(1)</script>', response.body
    assert_match '&lt;script&gt;alert(1)&lt;/script&gt;', response.body
  end

  test 'json show does not include unescaped script tags' do
    xss = Candidate.create!(
      first_name: '<script>alert(1)</script>',
      last_name: 'Doe',
      candidate_status: @hired_status
    )
    login_as 'admin'
    get candidate_path(xss, format: :json)
    assert_response :success
    # The JSON encoder must not emit a literal closing </script> tag.
    assert_no_match %r{</script>}, response.body
  end
end
