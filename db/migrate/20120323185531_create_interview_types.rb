class CreateInterviewTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :interview_types do |t|
      t.string :code
      t.string :name
      t.string :description
    end
  end
end
