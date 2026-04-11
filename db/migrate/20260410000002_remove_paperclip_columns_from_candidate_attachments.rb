class RemovePaperclipColumnsFromCandidateAttachments < ActiveRecord::Migration[7.1]
  def up
    remove_column :candidate_attachments, :attachment_file_name, :string
    remove_column :candidate_attachments, :attachment_content_type, :string
    remove_column :candidate_attachments, :attachment_file_size, :bigint
    remove_column :candidate_attachments, :attachment_updated_at, :datetime
  end

  def down
    add_column :candidate_attachments, :attachment_file_name, :string
    add_column :candidate_attachments, :attachment_content_type, :string
    add_column :candidate_attachments, :attachment_file_size, :bigint
    add_column :candidate_attachments, :attachment_updated_at, :datetime
  end
end
