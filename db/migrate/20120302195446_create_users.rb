class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.boolean :admin
      t.boolean :active
      t.string :auth_name
      t.string :user_name

      t.timestamps
    end
  end
end
