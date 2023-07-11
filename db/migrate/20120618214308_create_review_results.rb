class CreateReviewResults < ActiveRecord::Migration[7.0]
  def up
    create_table :review_results do |t|
      t.string :code
      t.string :name
      t.string :description
      t.boolean :is_approval
      t.boolean :is_disapproval
    end

    change_table :interview_reviews do |t|
      t.references :review_result
    end

    change_table :code_submission_reviews do |t|
      t.references :review_result
    end

    execute <<-SQL
      ALTER TABLE interview_reviews
        ADD CONSTRAINT fk_interview_rev_res
        FOREIGN KEY (review_result_id)
        REFERENCES review_results(id)
    SQL

    execute <<-SQL
      ALTER TABLE code_submission_reviews
        ADD CONSTRAINT fk_submission_rev_res
        FOREIGN KEY (review_result_id)
        REFERENCES review_results(id)
    SQL

  end

  def down
    execute <<-SQL
      ALTER TABLE code_submission_reviews
        DROP FOREIGN KEY fk_submission_rev_res
    SQL

    execute <<-SQL
      ALTER TABLE interview_reviews
        DROP FOREIGN KEY fk_interview_rev_res
    SQL

    remove_column :code_submission_reviews, :review_result_id
    remove_column :interview_reviews, :review_result_id

    drop_table :review_results
  end
end
