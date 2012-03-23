class CreateCandidateSources < ActiveRecord::Migration
  def change
    create_table :candidate_sources do |t|
      t.string :code
      t.string :name
      t.string :description
    end
  end
end
