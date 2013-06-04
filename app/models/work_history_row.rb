class WorkHistoryRow < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :previous_employer

  def summary
    "#{start_date.to_s} - #{end_date.to_s} (#{previous_employer.name})"
  end
end
