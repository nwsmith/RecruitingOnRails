class FixGendersColumnInCandidates < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_genders
    SQL

    rename_column :candidates, :genders_id, :gender_id

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_genders
        FOREIGN KEY (gender_id)
        REFERENCES genders(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_genders
    SQL

    rename_column :candidates, :gender_id, :genders_id

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_genders
        FOREIGN KEY (genders_id)
        REFERENCES genders(id)
    SQL
  end
end