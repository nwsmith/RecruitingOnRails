class CodeSubmission < ActiveRecord::Base
  belongs_to :code_problem
  belongs_to :candidate
end
