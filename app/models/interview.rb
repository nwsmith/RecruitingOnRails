class Interview < ApplicationRecord
  belongs_to :interview_type
  belongs_to :candidate
  has_many :interview_reviews

  def long_name
    (interview_type.nil? ? 'N/A' : interview_type.name) + '  w/ ' + candidate.name
  end

  def name
    interview_type.nil? ? 'N/A' : interview_type.name
  end

  def reviews
    interview_reviews
  end

  def event_date
    meeting_time
  end
end
