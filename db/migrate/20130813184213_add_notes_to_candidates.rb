class AddNotesToCandidates < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :notes, :string
  end
end
