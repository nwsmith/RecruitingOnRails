class CodeSubmissionReview < ActiveRecord::Base
  belongs_to :code_submission
  belongs_to :user
end
