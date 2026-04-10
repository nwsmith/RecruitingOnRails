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

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
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
end
