class Interview < ActiveRecord::Base
  belongs_to :interview_type
  belongs_to :candidate
  has_many :interview_reviews

  def name
    interview_type.name + "  w/ " + candidate.name
  end

  def reviews
    interview_reviews
  end
end
