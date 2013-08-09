class AddNotesToCodeReviews < ActiveRecord::Migration
  def change
    add_column :code_submissions, :notes, :string
  end
end
