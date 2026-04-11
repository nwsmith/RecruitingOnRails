class ReferenceCheck < ApplicationRecord
  include Trackable

  belongs_to :candidate
  belongs_to :review_result, optional: true

  def audit_candidate_id
    candidate_id
  end
end
