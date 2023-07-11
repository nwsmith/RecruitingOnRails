class CreateCodeSubmissionReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :code_submission_reviews do |t|
      t.references :code_submission
      t.references :user
      t.boolean :approved
      t.string :notes

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE code_submission_reviews
        ADD CONSTRAINT fk_code_submission_review_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
    SQL

    execute <<-SQL
      ALTER TABLE code_submission_reviews
        ADD CONSTRAINT fk_code_submission_review
        FOREIGN KEY (code_submission_id)
        REFERENCES code_submissions(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE code_submission_reviews
        DROP FOREIGN KEY fk_code_submission_review_user
    SQL

    execute <<-SQL
      ALTER TABLE code_submission_reviews
        DROP FOREIGN KEY fk_code_submission_review
    SQL

    drop_table :code_submissions
  end
end
