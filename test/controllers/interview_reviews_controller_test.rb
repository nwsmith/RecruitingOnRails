require "test_helper"

# InterviewReviews don't carry a check_staff/check_admin gate beyond the
# standard check_login: any logged-in employee can create a review of any
# interview, including ones conducted by other users. That's the workflow
# ("any reviewer can review any interview") and it's the current intentional
# behavior. The tests below encode that. The orthogonal gap — that any
# logged-in user can edit/destroy ANY review regardless of authorship —
# would need per-record access control to fix, which is out of scope here.
# Documenting it so future drift on either dimension is visible.
class InterviewReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status         = CandidateStatus.create!(code: "PEND", name: "Pending")
    @candidate      = Candidate.create!(first_name: "Interview", last_name: "Candidate", candidate_status: @status)
    @interview_type = InterviewType.create!(code: "TECH", name: "Technical", description: "Tech interview")
    @interview = Interview.create!(
      candidate: @candidate, interview_type: @interview_type,
      meeting_time: Date.today, notes: "Initial screen"
    )
    @review_result = ReviewResult.create!(
      code: "PASS", name: "Pass", is_approval: true, is_disapproval: false
    )
    @target = InterviewReview.create!(
      interview: @interview,
      user_id: User.find_by(user_name: "admin")&.id || User.first.id,
      review_result: @review_result,
      notes: "Solid candidate"
    )
  end


  # ----- login required -----

  test "unauthenticated index redirects to login" do
    get interview_reviews_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "unauthenticated show redirects to login" do
    get interview_review_path(@target)
    assert_redirected_to controller: "login", action: "index"
  end

  test "unauthenticated new redirects to login" do
    get new_interview_review_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "unauthenticated create redirects to login" do
    assert_no_difference -> { InterviewReview.count } do
      post interview_reviews_path, params: { interview_review: valid_attrs }
    end
    assert_redirected_to controller: "login", action: "index"
  end

  # ----- logged-in user happy paths (intentionally permissive: any
  # employee can review any interview, see comment at top of class) -----

  test "admin can list interview reviews" do
    login_as "admin"
    get interview_reviews_path
    assert_response :success
  end

  test "admin can view an interview review" do
    login_as "admin"
    get interview_review_path(@target)
    assert_response :success
  end

  test "admin can render the new form prefilled with interview_id and current_user" do
    login_as "admin"
    get new_interview_review_path(interview_id: @interview.id)
    assert_response :success
    # The new action sets @interview_review.interview_id = params[:interview_id]
    # and @interview_review.user_id = current_user.id. The rendered form
    # should carry both as hidden values.
    assert_match @interview.id.to_s, response.body
  end

  test "regular logged-in user can also reach the new form" do
    login_as "regular"
    get new_interview_review_path(interview_id: @interview.id)
    assert_response :success
  end

  test "admin can render the edit form" do
    login_as "admin"
    get edit_interview_review_path(@target)
    assert_response :success
  end

  test "admin can create an interview review" do
    login_as "admin"
    assert_difference -> { InterviewReview.count }, 1 do
      post interview_reviews_path, params: { interview_review: valid_attrs }
    end
    created = InterviewReview.last
    assert_redirected_to interview_review_path(created)
    assert_equal @interview.id, created.interview_id
    assert_equal @review_result.id, created.review_result_id
  end

  test "regular logged-in user can also create an interview review" do
    login_as "regular"
    assert_difference -> { InterviewReview.count }, 1 do
      post interview_reviews_path, params: { interview_review: valid_attrs }
    end
  end

  test "admin can update an interview review" do
    login_as "admin"
    patch interview_review_path(@target), params: { interview_review: { notes: "Updated notes" } }
    assert_redirected_to interview_review_path(@target)
    assert_equal "Updated notes", @target.reload.notes
  end

  test "admin can destroy an interview review" do
    login_as "admin"
    assert_difference -> { InterviewReview.count }, -1 do
      delete interview_review_path(@target)
    end
    assert_redirected_to interview_reviews_path
  end

  test "admin json index returns success" do
    login_as "admin"
    get interview_reviews_path(format: :json)
    assert_response :success
  end

  test "admin json show returns success" do
    login_as "admin"
    get interview_review_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    {
      interview_id: @interview.id,
      user_id: User.find_by(user_name: "admin")&.id || User.first.id,
      review_result_id: @review_result.id,
      notes: "Strong technical answers"
    }
  end
end
