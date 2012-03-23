class CreateInterviewReviews < ActiveRecord::Migration
  def up
    create_table :interview_reviews do |t|
      t.references :user
      t.references :interview
      t.boolean :approved
      t.string :notes

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE interview_reviews
        ADD CONSTRAINT fk_interview_review_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
    SQL

    execute <<-SQL
      ALTER TABLE interview_reviews
        ADD CONSTRAINT fk_interview_review_interview
        FOREIGN KEY (interview_id)
        REFERENCES interviews(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE interview_reviews
        DROP FOREIGN KEY fk_interview_review_user
    SQL

    execute <<-SQL
      ALTER TABLE interview_reviews
        DROP FOREIGN KEY fk_interview_review_interview
    SQL

    drop_table :interview_reviews
  end
end
