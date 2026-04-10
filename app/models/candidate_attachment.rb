class CandidateAttachment < ApplicationRecord
  belongs_to :candidate

  has_one_attached :attachment

  ALLOWED_CONTENT_TYPES = %w[application/pdf application/msword text/plain].freeze
  MAX_ATTACHMENT_BYTES = 10.megabytes

  validate :attachment_content_type
  validate :attachment_size

  private

  def attachment_content_type
    return unless attachment.attached?
    return if ALLOWED_CONTENT_TYPES.include?(attachment.content_type)

    errors.add(:attachment, "must be one of: #{ALLOWED_CONTENT_TYPES.join(', ')}")
  end

  def attachment_size
    return unless attachment.attached?
    return if attachment.byte_size <= MAX_ATTACHMENT_BYTES

    errors.add(:attachment, "must be smaller than #{MAX_ATTACHMENT_BYTES / 1.megabyte} MB")
  end
end
