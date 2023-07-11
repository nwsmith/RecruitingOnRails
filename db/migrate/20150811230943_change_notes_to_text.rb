class ChangeNotesToText < ActiveRecord::Migration[7.0]
  def up
    change_column :candidates, :notes, :text
    change_column :code_submissions, :notes, :text
    change_column :code_submission_reviews, :notes, :text
    change_column :reference_checks, :notes, :text
  end

  def down
    change_column :candidates, :notes, :string
    change_column :code_submissions, :notes, :string
    change_column :code_submission_reviews, :notes, :string
    change_column :reference_checks, :notes, :string
  end
end
