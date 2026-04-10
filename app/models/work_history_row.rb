class WorkHistoryRow < ApplicationRecord
  belongs_to :candidate
  belongs_to :previous_employer, optional: true

  def summary
    end_date_string = end_date.nil? ? 'Present' : end_date.to_s


    "#{start_date.to_s} - #{end_date_string} (#{previous_employer&.name || 'N/A'})"
  end
end
