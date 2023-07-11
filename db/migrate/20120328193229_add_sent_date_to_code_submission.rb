class AddSentDateToCodeSubmission < ActiveRecord::Migration[7.0]
  def change
    add_column :code_submissions, :sent_date, :date
  end
end
