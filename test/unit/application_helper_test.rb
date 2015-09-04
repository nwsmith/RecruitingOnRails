require 'test/unit'
require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def test_approval_type_nil
    assert_equal(:approval_unknown, approval_type(nil))
  end

  def test_approval_type_empty_review_result
    assert_equal(:approval_unknown, approval_type(ReviewResult.new))
  end

  def test_approval_type_approved
    review_result = ReviewResult.new
    review_result.is_approval = true
    assert_equal(:approved, approval_type(review_result))
  end

  def test_approval_type_disapproved
    review_result = ReviewResult.new
    review_result.is_disapproval = true
    assert_equal(:not_approved, approval_type(review_result))
  end

  def test_approval_type_disapproved_trumps_approved
    review_result = ReviewResult.new
    review_result.is_approval = true
    review_result.is_disapproval = true
    assert_equal(:not_approved, approval_type(review_result))
  end

  def test_approval_type_empty_code_submission_review
    assert_equal(:approval_unknown, approval_type(CodeSubmissionReview.new))
  end

  def test_approval_type_code_submission_review_review_result_with_no_flags
    code_submission_review = CodeSubmissionReview.new
    code_submission_review.review_result = ReviewResult.new
    assert_equal(:approval_unknown, approval_type(code_submission_review))
  end

  def test_approval_type_code_submission_review_result_approved
    code_submission_review = CodeSubmissionReview.new
    review_result = ReviewResult.new
    review_result.is_approval = true
    code_submission_review.review_result = review_result
    assert_equal(:approved, approval_type(code_submission_review))
  end

  def test_approval_type_code_submission_review_result_not_approved
    code_submission_review = CodeSubmissionReview.new
    review_result = ReviewResult.new
    review_result.is_disapproval = true
    code_submission_review.review_result = review_result
    assert_equal(:not_approved, approval_type(code_submission_review))
  end

  def test_approval_type_code_submission_empty
    assert_equal(:approval_unknown, approval_type(CodeSubmission.new))
  end

  def test_approval_type_code_submission_one_empty_review
    code_submission = CodeSubmission.new
    code_submission.reviews << CodeSubmissionReview.new
    assert_equal(:approval_unknown, approval_type(code_submission))
  end

  def test_approval_type_code_submission_one_unknown_review
    code_submission_review = CodeSubmissionReview.new
    code_submission_review.review_result = ReviewResult.new
    code_submission = CodeSubmission.new
    code_submission.reviews << code_submission_review
    assert_equal(:approval_unknown, approval_type(code_submission))
  end

  def test_approval_type_code_submission_one_approved_review
    review_result = ReviewResult.new
    review_result.is_approval = true
    code_submission_review = CodeSubmissionReview.new
    code_submission_review.review_result = review_result
    code_submission = CodeSubmission.new
    code_submission.reviews << code_submission_review
    assert_equal(:approved, approval_type(code_submission))
  end

  def test_approval_type_code_submission_one_unapproved_review
    review_result = ReviewResult.new
    review_result.is_disapproval = true
    code_submission_review = CodeSubmissionReview.new
    code_submission_review.review_result = review_result
    code_submission = CodeSubmission.new
    code_submission.reviews << code_submission_review
    assert_equal(:not_approved, approval_type(code_submission))
  end

  def test_approval_type_code_submission_one_approved_one_empty_review
    review_result = ReviewResult.new
    review_result.is_approval = true
    code_submission_review = CodeSubmissionReview.new
    code_submission_review.review_result = review_result
    code_submission = CodeSubmission.new
    code_submission.reviews << code_submission_review
    code_submission.reviews << CodeSubmissionReview.new
    assert_equal(:approval_unknown, approval_type(code_submission))
  end

  def test_approval_type_code_submission_one_disapproved_one_empty_review
    review_result = ReviewResult.new
    review_result.is_disapproval = true
    code_submission_review = CodeSubmissionReview.new
    code_submission_review.review_result = review_result
    code_submission = CodeSubmission.new
    code_submission.reviews << code_submission_review
    code_submission.reviews << CodeSubmissionReview.new
    assert_equal(:not_approved, approval_type(code_submission))

    # To make sure order doesn't matter
    code_submission.reviews.clear
    code_submission.reviews << CodeSubmissionReview.new
    code_submission.reviews << code_submission_review
    assert_equal(:not_approved, approval_type(code_submission))
  end

  def test_approval_type_code_submission_one_disapproved_one_approved
    approved_result = ReviewResult.new
    approved_result.is_approval = true
    unapproved_result = ReviewResult.new
    unapproved_result.is_disapproval = true
    approved_review = CodeSubmissionReview.new
    approved_review.review_result = approved_result
    unapproved_review = CodeSubmissionReview.new
    unapproved_review.review_result = unapproved_result
    code_submission = CodeSubmission.new
    code_submission.reviews << approved_review
    code_submission.reviews << unapproved_review
    assert_equal(:not_approved, approval_type(code_submission))

    #To make sure order doesn't matter
    code_submission.reviews.clear
    code_submission.reviews << unapproved_review
    code_submission.reviews << approved_review
    assert_equal(:not_approved, approval_type(code_submission))
  end

end