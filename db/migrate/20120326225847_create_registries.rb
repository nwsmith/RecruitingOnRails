class CreateRegistries < ActiveRecord::Migration
  def change
    create_table :registries do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
