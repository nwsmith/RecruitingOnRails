class AddColorToExperienceLevel < ActiveRecord::Migration
  def change
    add_column :experience_levels, :color, :string
  end
end
