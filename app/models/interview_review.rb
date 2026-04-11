class InterviewReview < ApplicationRecord
  include Trackable

  belongs_to :interview
  belongs_to :user
  belongs_to :review_result, optional: true

  def audit_candidate_id
    interview&.candidate_id
  end
end
