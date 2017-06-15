class CandidateAttachment < ActiveRecord::Base
  belongs_to :candidate

  attr_accessible :attachment, :candidate_id, :notes

  has_attached_file :attachment
  validates_attachment_content_type :attachment, :content_type => %w(application/pdf application/msword text/plain)

end
