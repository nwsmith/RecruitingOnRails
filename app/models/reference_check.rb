class ReferenceCheck < ApplicationRecord
  belongs_to :candidate
  belongs_to :review_result
end
