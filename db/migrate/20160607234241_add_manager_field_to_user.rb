class AddManagerFieldToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :manager, :boolean
    add_column :users, :hr, :boolean
  end
end
