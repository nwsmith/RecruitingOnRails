require 'test_helper'

class InterviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @candidate = Candidate.create!(
      first_name: 'Jane',
      last_name: 'Doe',
      candidate_status: @status
    )
    @interview_type = InterviewType.create!(name: 'Phone Screen')
    @interview = Interview.create!(
      candidate: @candidate,
      interview_type: @interview_type,
      meeting_time: Time.current,
      notes: 'Initial chat'
    )
  end


  # ----- auth -----

  test 'unauthenticated request to index redirects to login' do
    get interviews_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'unauthenticated request to show redirects to login' do
    get interview_path(@interview)
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'unauthenticated create is rejected' do
    assert_no_difference -> { Interview.count } do
      post interviews_path, params: { interview: { candidate_id: @candidate.id } }
    end
    assert_redirected_to controller: 'login', action: 'index'
  end

  # ----- index / show -----

  test 'admin can list interviews' do
    login_as 'admin'
    get interviews_path
    assert_response :success
  end

  test 'admin can list interviews as json' do
    login_as 'admin'
    get interviews_path(format: :json)
    assert_response :success
    assert_equal 'application/json', response.media_type
  end

  test 'admin can view a single interview' do
    login_as 'admin'
    get interview_path(@interview)
    assert_response :success
  end

  # ----- new / create -----

  test 'new prefills candidate_id from query param' do
    login_as 'admin'
    get new_interview_path(candidate_id: @candidate.id)
    assert_response :success
    # The candidate select should have the requested candidate pre-selected.
    assert_match %r{<option selected="selected" value="#{@candidate.id}">}, response.body
  end

  test 'create with valid params persists the interview' do
    login_as 'admin'
    assert_difference -> { Interview.count }, 1 do
      post interviews_path, params: {
        interview: {
          candidate_id: @candidate.id,
          interview_type_id: @interview_type.id,
          meeting_time: 1.day.from_now,
          notes: 'Followup'
        }
      }
    end
    assert_redirected_to interview_path(Interview.last)
  end

  test 'create as json returns the new interview' do
    login_as 'admin'
    assert_difference -> { Interview.count }, 1 do
      post interviews_path(format: :json), params: {
        interview: {
          candidate_id: @candidate.id,
          interview_type_id: @interview_type.id,
          meeting_time: 1.day.from_now,
          notes: 'Json create'
        }
      }
    end
    assert_response :created
    body = JSON.parse(response.body)
    assert_equal @candidate.id, body['candidate_id']
  end

  # ----- update / destroy -----

  test 'update changes notes' do
    login_as 'admin'
    patch interview_path(@interview), params: { interview: { notes: 'Updated notes' } }
    assert_redirected_to interview_path(@interview)
    assert_equal 'Updated notes', @interview.reload.notes
  end

  test 'destroy removes the interview' do
    login_as 'admin'
    assert_difference -> { Interview.count }, -1 do
      delete interview_path(@interview)
    end
    assert_redirected_to interviews_path
  end

  # ----- per-candidate auth gates -----

  test 'regular user cannot list interviews (staff only)' do
    login_as 'regular'
    get interviews_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'hr can list interviews' do
    login_as 'hruser'
    get interviews_path
    assert_response :success
  end

  test 'manager can list interviews' do
    login_as 'manager'
    get interviews_path
    assert_response :success
  end

  test 'regular user cannot view another candidates interview' do
    login_as 'regular'
    get interview_path(@interview)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot edit another candidates interview' do
    login_as 'regular'
    get edit_interview_path(@interview)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update another candidates interview' do
    login_as 'regular'
    patch interview_path(@interview), params: { interview: { notes: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Initial chat', @interview.reload.notes
  end

  test 'regular user cannot destroy another candidates interview' do
    login_as 'regular'
    assert_no_difference -> { Interview.count } do
      delete interview_path(@interview)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create an interview for another candidate' do
    login_as 'regular'
    assert_no_difference -> { Interview.count } do
      post interviews_path, params: {
        interview: {
          candidate_id: @candidate.id,
          interview_type_id: @interview_type.id,
          meeting_time: 1.day.from_now
        }
      }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'self candidate user can view their own pending candidates interview' do
    self_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @status
    )
    own_interview = Interview.create!(
      candidate: self_candidate,
      interview_type: @interview_type,
      meeting_time: Time.current
    )
    login_as 'self.candidate'
    get interview_path(own_interview)
    assert_response :success
  end

  test 'self candidate user cannot view their own interview after hire' do
    hired = CandidateStatus.create!(code: 'HIRED', name: 'Hired')
    self_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: hired
    )
    own_interview = Interview.create!(
      candidate: self_candidate,
      interview_type: @interview_type,
      meeting_time: Time.current
    )
    login_as 'self.candidate'
    get interview_path(own_interview)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end
end
