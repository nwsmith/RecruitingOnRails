class CreateCodeSubmissions < ActiveRecord::Migration[7.0]
  def up
    create_table :code_submissions do |t|
      t.references :code_problem
      t.references :candidate
      t.date :submission_date
      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE code_submissions
        ADD CONSTRAINT fk_code_submission_problem
        FOREIGN KEY (code_problem_id)
        REFERENCES code_problems(id)
    SQL

    execute <<-SQL
      ALTER TABLE code_submissions
        ADD CONSTRAINT fk_code_submission_candidate
        FOREIGN KEY (candidate_id)
        REFERENCES candidates(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE code_submissions
        DROP FOREIGN KEY fk_code_submission_problem
    SQL

    execute <<-SQL
      ALTER TABLE code_submissions
        DROP FOREIGN KEY fk_code_submission_candidate
    SQL

    drop_table :code_submissions
  end

end
