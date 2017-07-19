class CreateDiaryEntryTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :diary_entry_types do |t|
      t.string :code
      t.string :name
      t.string :description
      t.boolean :positive
      t.boolean :negative
    end
  end
end
