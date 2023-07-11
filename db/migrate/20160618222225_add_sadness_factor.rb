class AddSadnessFactor < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :sadness_factor, :integer
  end
end
