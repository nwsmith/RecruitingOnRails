class CreateCandidateAttachments < ActiveRecord::Migration[7.0]
  def up
    create_table :candidate_attachments do |t|
      t.string :notes
      t.attachment :attachment
      t.references :candidate
    end


    execute <<-SQL
      ALTER TABLE candidate_attachments
        ADD CONSTRAINT fk_attachment_candidate
        FOREIGN KEY (candidate_id)
        REFERENCES candidates(id)
    SQL

  end

  def down
    execute <<-SQL
      ALTER TABLE candidate_attachments
        DROP FOREIGN KEY fk_attachment_candidate
    SQL

    drop_table :candidate_attachments
  end
end
