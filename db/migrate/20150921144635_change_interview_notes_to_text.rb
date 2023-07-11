class ChangeInterviewNotesToText < ActiveRecord::Migration[7.0]
  def up
    change_column :interviews, :notes, :text
    change_column :interview_reviews, :notes, :text
  end

  def down
    change_column :interviews, :notes, :string
    change_column :interview_reviews, :notes, :string
  end
end
