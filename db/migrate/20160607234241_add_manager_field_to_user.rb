class AddManagerFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :manager, :boolean
    add_column :users, :hr, :boolean
  end
end
