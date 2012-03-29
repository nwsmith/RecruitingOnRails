class CodeSubmission < ActiveRecord::Base
  belongs_to :code_problem
  belongs_to :candidate
  has_many :code_submission_reviews

  def name
    "#{code_problem.nil? ? 'N/A' : code_problem.name} (#{candidate.name})"
  end
end
