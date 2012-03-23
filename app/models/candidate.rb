class Candidate < ActiveRecord::Base
  belongs_to :candidate_status
  belongs_to :candidate_source
end
