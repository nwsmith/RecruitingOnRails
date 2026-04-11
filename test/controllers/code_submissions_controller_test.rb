require 'test_helper'

class CodeSubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @candidate = Candidate.create!(
      first_name: 'Jane',
      last_name: 'Doe',
      candidate_status: @status
    )
    @problem = CodeProblem.create!(name: 'Fizzbuzz')
    @submission = CodeSubmission.create!(
      candidate: @candidate,
      code_problem: @problem,
      sent_date: 1.week.ago.to_date,
      notes: 'Initial send'
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  # ----- auth -----

  test 'unauthenticated index redirects to login' do
    get code_submissions_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'unauthenticated show redirects to login' do
    get code_submission_path(@submission)
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'unauthenticated create is rejected' do
    assert_no_difference -> { CodeSubmission.count } do
      post code_submissions_path, params: { code_submission: { candidate_id: @candidate.id } }
    end
    assert_redirected_to controller: 'login', action: 'index'
  end

  # ----- index / show -----

  test 'admin can list submissions' do
    login_as 'admin'
    get code_submissions_path
    assert_response :success
  end

  test 'admin can list submissions as json' do
    login_as 'admin'
    get code_submissions_path(format: :json)
    assert_response :success
    assert_equal 'application/json', response.media_type
  end

  test 'admin can view a submission' do
    login_as 'admin'
    get code_submission_path(@submission)
    assert_response :success
  end

  # ----- new / create -----

  test 'new prefills candidate_id from query param' do
    login_as 'admin'
    get new_code_submission_path(candidate_id: @candidate.id)
    assert_response :success
    assert_match %r{<option selected="selected" value="#{@candidate.id}">}, response.body
  end

  test 'create with valid params persists the submission' do
    login_as 'admin'
    assert_difference -> { CodeSubmission.count }, 1 do
      post code_submissions_path, params: {
        code_submission: {
          candidate_id: @candidate.id,
          code_problem_id: @problem.id,
          sent_date: Date.today,
          notes: 'Followup problem'
        }
      }
    end
    assert_redirected_to code_submission_path(CodeSubmission.last)
  end

  test 'create as json returns the new submission' do
    login_as 'admin'
    assert_difference -> { CodeSubmission.count }, 1 do
      post code_submissions_path(format: :json), params: {
        code_submission: {
          candidate_id: @candidate.id,
          code_problem_id: @problem.id,
          sent_date: Date.today
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
    patch code_submission_path(@submission), params: { code_submission: { notes: 'Updated' } }
    assert_redirected_to code_submission_path(@submission)
    assert_equal 'Updated', @submission.reload.notes
  end

  test 'destroy removes the submission' do
    login_as 'admin'
    assert_difference -> { CodeSubmission.count }, -1 do
      delete code_submission_path(@submission)
    end
    assert_redirected_to code_submissions_path
  end
end
