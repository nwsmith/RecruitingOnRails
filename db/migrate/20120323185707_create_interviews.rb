class CreateInterviews < ActiveRecord::Migration[7.0]
  def up
    create_table :interviews do |t|
      t.datetime :meeting_time
      t.string :notes
      t.references :interview_type
      t.references :candidate
    end

    execute <<-SQL
      ALTER TABLE interviews
        ADD CONSTRAINT fk_interview_type
        FOREIGN KEY (interview_type_id)
        REFERENCES interview_types(id)
    SQL

    execute <<-SQL
      ALTER TABLE interviews
        ADD CONSTRAINT fk_interview_candidate
        FOREIGN KEY (candidate_id)
        REFERENCES candidates(id)
    SQL

  end

  def down
    execute <<-SQL
      ALTER TABLE interviews
        DROP FOREIGN KEY fk_interview_typeø
    SQL

    execute <<-SQL
      ALTER TABLE interviews
        DROP FOREIGN KEY fk_interview_candidate
    SQL

    drop_table :interviews
  end
end
