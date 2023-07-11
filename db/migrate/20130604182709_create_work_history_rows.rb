class CreateWorkHistoryRows < ActiveRecord::Migration[7.0]
  def up
    create_table :work_history_rows do |t|
      t.date :start_date
      t.date :end_date
      t.references :previous_employer
      t.references :candidate
    end

    execute <<-SQL
      ALTER TABLE work_history_rows
        ADD CONSTRAINT fk_previous_employer
        FOREIGN KEY (previous_employer_id)
        REFERENCES previous_employers(id)
    SQL

    execute <<-SQL
      ALTER TABLE work_history_rows
        ADD CONSTRAINT fk_history_candidate
        FOREIGN KEY (candidate_id)
        REFERENCES candidates(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE work_history_rows
        DROP FOREIGN KEY fk_previous_employer
    SQL

    execute <<-SQL
      ALTER TABLE work_history_rows
        DROP FOREIGN KEY fk_history_candidate
    SQL

    drop_table :work_history_rows
  end
end
