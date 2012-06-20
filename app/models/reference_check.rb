class ReferenceCheck < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :review_result
end
