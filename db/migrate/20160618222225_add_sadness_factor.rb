class AddSadnessFactor < ActiveRecord::Migration
  def change
    add_column :candidates, :sadness_factor, :integer
  end
end
