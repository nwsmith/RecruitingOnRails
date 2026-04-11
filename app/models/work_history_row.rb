class WorkHistoryRow < ApplicationRecord
  include Trackable

  belongs_to :candidate
  belongs_to :previous_employer, optional: true

  def audit_candidate_id
    candidate_id
  end

  def summary
    end_date_string = end_date.nil? ? "Present" : end_date.to_s


    "#{start_date} - #{end_date_string} (#{previous_employer&.name || 'N/A'})"
  end
end
