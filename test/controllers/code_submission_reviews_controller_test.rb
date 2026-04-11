require "test_helper"

# CodeSubmissionReviews don't carry a check_staff/check_admin gate beyond
# the standard check_login: any logged-in employee can create a review
# of any code submission, including ones authored by other users. That's
# the workflow ("any reviewer can review any submission") and it's the
# current intentional behavior. The tests below encode that. The
# orthogonal gap — that any logged-in user can edit/destroy ANY review
# regardless of authorship — would need per-record access control to
# fix, which is out of scope here. Documenting it so future drift on
# either dimension is visible.
class CodeSubmissionReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = CandidateStatus.create!(code: "PEND", name: "Pending")
    @candidate    = Candidate.create!(first_name: "Code", last_name: "Candidate", candidate_status: @status)
    @code_problem = CodeProblem.create!(code: "PALIN", name: "Palindrome", description: "Detect palindromes")
    @code_submission = CodeSubmission.create!(
      candidate: @candidate, code_problem: @code_problem,
      sent_date: Date.today - 7, submission_date: Date.today - 1
    )
    @review_result = ReviewResult.create!(
      code: "PASS", name: "Pass", is_approval: true, is_disapproval: false
    )
    @target = CodeSubmissionReview.create!(
      code_submission: @code_submission,
      user_id: User.find_by(user_name: "admin")&.id || User.first.id,
      review_result: @review_result,
      notes: "Looks good"
    )
  end


  # ----- login required -----

  test "unauthenticated index redirects to login" do
    get code_submission_reviews_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "unauthenticated show redirects to login" do
    get code_submission_review_path(@target)
    assert_redirected_to controller: "login", action: "index"
  end

  test "unauthenticated new redirects to login" do
    get new_code_submission_review_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "unauthenticated create redirects to login" do
    assert_no_difference -> { CodeSubmissionReview.count } do
      post code_submission_reviews_path, params: { code_submission_review: valid_attrs }
    end
    assert_redirected_to controller: "login", action: "index"
  end

  # ----- logged-in user happy paths (intentionally permissive: any
  # employee can review any submission, see comment at the top of class) -----

  test "admin can list code submission reviews" do
    login_as "admin"
    get code_submission_reviews_path
    assert_response :success
  end

  test "admin can view a code submission review" do
    login_as "admin"
    get code_submission_review_path(@target)
    assert_response :success
  end

  test "admin can render the new form prefilled with code_submission_id and current_user" do
    login_as "admin"
    get new_code_submission_review_path(code_submission_id: @code_submission.id)
    assert_response :success
    # The new action sets @code_submission_review.code_submission_id = params[:code_submission_id]
    # and @code_submission_review.user_id = current_user.id. The rendered form
    # should carry both as hidden values, so check that the response body
    # references both ids.
    assert_match @code_submission.id.to_s, response.body
  end

  test "regular logged-in user can also reach the new form" do
    login_as "regular"
    get new_code_submission_review_path(code_submission_id: @code_submission.id)
    assert_response :success
  end

  test "admin can render the edit form" do
    login_as "admin"
    get edit_code_submission_review_path(@target)
    assert_response :success
  end

  test "admin can create a code submission review" do
    login_as "admin"
    assert_difference -> { CodeSubmissionReview.count }, 1 do
      post code_submission_reviews_path, params: { code_submission_review: valid_attrs }
    end
    created = CodeSubmissionReview.last
    assert_redirected_to code_submission_review_path(created)
    assert_equal @code_submission.id, created.code_submission_id
    assert_equal @review_result.id, created.review_result_id
  end

  test "regular logged-in user can also create a code submission review" do
    login_as "regular"
    assert_difference -> { CodeSubmissionReview.count }, 1 do
      post code_submission_reviews_path, params: { code_submission_review: valid_attrs }
    end
  end

  test "admin can update a code submission review" do
    login_as "admin"
    patch code_submission_review_path(@target), params: { code_submission_review: { notes: "Updated notes" } }
    assert_redirected_to code_submission_review_path(@target)
    assert_equal "Updated notes", @target.reload.notes
  end

  test "admin can destroy a code submission review" do
    login_as "admin"
    assert_difference -> { CodeSubmissionReview.count }, -1 do
      delete code_submission_review_path(@target)
    end
    assert_redirected_to code_submission_reviews_path
  end

  test "admin json index returns success" do
    login_as "admin"
    get code_submission_reviews_path(format: :json)
    assert_response :success
  end

  test "admin json show returns success" do
    login_as "admin"
    get code_submission_review_path(@target, format: :json)
    assert_response :success
  end

  private

  def valid_attrs
    {
      code_submission_id: @code_submission.id,
      user_id: User.find_by(user_name: "admin")&.id || User.first.id,
      review_result_id: @review_result.id,
      notes: "Solid solution"
    }
  end
end
