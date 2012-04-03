class Candidate < ActiveRecord::Base
  belongs_to :candidate_status
  belongs_to :candidate_source
  belongs_to :experience_level
  belongs_to :position
  belongs_to :education_level
  belongs_to :school
  has_many :interviews
  has_many :code_submissions

  def name
    first_name + " " + last_name
  end

  def Candidate.by_status_code(status_code)
    status = CandidateStatus.first(:conditions => {:code => status_code})
    id = status.nil? ? -1 : status.id
    Candidate.all(:conditions => {:candidate_status_id => id})
  end
end
