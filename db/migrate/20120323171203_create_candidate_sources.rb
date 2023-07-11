class CreateCandidateSources < ActiveRecord::Migration[7.0]
  def change
    create_table :candidate_sources do |t|
      t.string :code
      t.string :name
      t.string :description
    end
  end
end
