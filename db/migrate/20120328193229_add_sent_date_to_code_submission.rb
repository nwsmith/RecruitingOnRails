class AddSentDateToCodeSubmission < ActiveRecord::Migration
  def change
    add_column :code_submissions, :sent_date, :date
  end
end
