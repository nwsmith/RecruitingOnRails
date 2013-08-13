class AddNotesToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :notes, :string
  end
end
