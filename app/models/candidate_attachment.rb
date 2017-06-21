class CandidateAttachment < ActiveRecord::Base
  belongs_to :candidate

  has_attached_file :attachment
  validates_attachment_content_type :attachment, :content_type => %w(application/pdf application/msword text/plain)

end
