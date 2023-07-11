class CreateCodeProblems < ActiveRecord::Migration[7.0]
  def change
    create_table :code_problems do |t|
      t.string :code
      t.string :name
      t.string :description
    end
  end
end
