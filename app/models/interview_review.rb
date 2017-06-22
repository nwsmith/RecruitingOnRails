class InterviewReview < ApplicationRecord
  belongs_to :interview
  belongs_to :user
  belongs_to :review_result
end
