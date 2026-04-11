class CodeSubmission < ApplicationRecord
  include Trackable

  belongs_to :code_problem, optional: true
  belongs_to :candidate
  has_many :code_submission_reviews

  def audit_candidate_id
    candidate_id
  end

  def name
    "#{code_problem.nil? ? 'N/A' : code_problem.name} (#{candidate.name})"
  end

  def reviews
    code_submission_reviews
  end

  def event_date
    submission_date.nil? ? sent_date : submission_date
  end
end
