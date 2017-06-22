class CodeSubmission < ApplicationRecord
  belongs_to :code_problem
  belongs_to :candidate
  has_many :code_submission_reviews

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
