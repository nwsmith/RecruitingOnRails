class CandidateAttachment < ApplicationRecord
  belongs_to :candidate

  has_one_attached :attachment

  validates :attachment, content_type: %w[application/pdf application/msword text/plain]
end
