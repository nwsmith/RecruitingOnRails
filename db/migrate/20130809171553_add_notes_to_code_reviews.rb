class AddNotesToCodeReviews < ActiveRecord::Migration[7.0]
  def change
    add_column :code_submissions, :notes, :string
  end
end
