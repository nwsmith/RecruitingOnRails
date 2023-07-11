class CreateCandidateStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :candidate_statuses do |t|
      t.string :code
      t.string :name
      t.string :description
    end
  end
end
