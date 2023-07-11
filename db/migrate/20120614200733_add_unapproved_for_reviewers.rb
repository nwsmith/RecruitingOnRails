class AddUnapprovedForReviewers < ActiveRecord::Migration[7.0]
  def change
    add_column :interview_reviews, :unapproved, :boolean
    add_column :code_submission_reviews, :unapproved, :boolean
  end

  def down
  end
end
