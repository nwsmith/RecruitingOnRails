class Candidate < ActiveRecord::Base
  belongs_to :candidate_status
  belongs_to :candidate_source
  belongs_to :experience_level
  has_many :interviews

  def name
    first_name + " " + last_name
  end
end
