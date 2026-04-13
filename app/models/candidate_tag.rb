class CandidateTag < ApplicationRecord
  include Trackable

  belongs_to :candidate
  belongs_to :tag

  def audit_candidate_id
    candidate_id
  end
end
