class CreateCandidates < ActiveRecord::Migration[7.0]
  def up
    create_table :candidates do |t|
      t.references :candidate_status
      t.references :candidate_source

      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.date :application_date
      t.date :first_contact_date
      t.boolean :is_referral
      t.string :referred_by

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_candidate_status
        FOREIGN KEY (candidate_status_id)
        REFERENCES candidate_statuses(id)
    SQL
    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_candidate_source
        FOREIGN KEY (candidate_source_id)
        REFERENCES candidate_sources(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_candidate_status
    SQL
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_candidate_source
    SQL
    drop_table :candidates
  end
end
