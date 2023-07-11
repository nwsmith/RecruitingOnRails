class CreateDiaryEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :diary_entries do |t|
      t.date :entry_date
      t.text :notes
    end

    add_reference(:diary_entries, :candidate, type: :bigint, foreign_key: true)
    add_reference(:diary_entries, :diary_entry_type, foreign_key: true)
    add_reference(:diary_entries, :user, type: :bigint, foreign_key: true)
  end
end
