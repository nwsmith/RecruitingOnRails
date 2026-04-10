class RemovePaperclipColumnsFromCandidateAttachments < ActiveRecord::Migration[7.1]
  GUARD_ENV = "I_HAVE_MIGRATED_PAPERCLIP_DATA".freeze

  def up
    unless ENV[GUARD_ENV] == "yes"
      raise <<~ERR
        ============================================================
        REFUSING to drop Paperclip metadata columns from candidate_attachments.

        This migration drops attachment_file_name, attachment_content_type,
        attachment_file_size, and attachment_updated_at without migrating
        the underlying S3 objects (bucket sum-resumes-prod, region us-east-2)
        into ActiveStorage's active_storage_blobs / active_storage_attachments
        tables.

        If existing CandidateAttachment rows have file data, running this
        migration will permanently disconnect every record from its S3 object.
        The objects themselves would remain in the bucket but become orphans.

        Before running this migration on any environment that may hold real
        attachment data:

          1. Decide whether to preserve existing attachments or accept the loss.
          2. If preserving: write and run a Paperclip-to-ActiveStorage data
             migration script first (one-shot rake task that, for each row
             with non-nil attachment_file_name, downloads from the Paperclip
             S3 path and re-attaches via has_one_attached).
          3. Confirm config.active_storage.service = :amazon is set in the
             target environment's environments/<env>.rb.
          4. Confirm S3_BUCKET=sum-resumes-prod (or appropriate bucket) is
             set in the deploy environment.

        When you have done the above, re-run with:

          #{GUARD_ENV}=yes bin/rails db:migrate

        On a fresh dev DB where there is no data to lose, the same env var
        bypasses the guard.
        ============================================================
      ERR
    end

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
