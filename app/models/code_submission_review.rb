class CodeSubmissionReview < ApplicationRecord
  include Trackable

  belongs_to :code_submission
  belongs_to :user
  belongs_to :review_result, optional: true

  def audit_candidate_id
    code_submission&.candidate_id
  end
end
