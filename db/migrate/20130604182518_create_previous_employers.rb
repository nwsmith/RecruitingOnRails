class CreatePreviousEmployers < ActiveRecord::Migration[7.0]
  def change
    create_table :previous_employers do |t|
      t.string :code
      t.string :name
      t.string :description
    end
  end
end
