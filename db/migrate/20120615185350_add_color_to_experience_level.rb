class AddColorToExperienceLevel < ActiveRecord::Migration[7.0]
  def change
    add_column :experience_levels, :color, :string
  end
end
