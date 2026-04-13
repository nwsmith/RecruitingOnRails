class CreateTagsAndCandidateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.string :name, null: false
      t.string :color
      t.timestamps
    end

    add_index :tags, :name, unique: true

    create_table :candidate_tags, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.bigint :candidate_id, null: false
      t.bigint :tag_id,       null: false
      t.datetime :created_at, null: false
    end

    add_index :candidate_tags, [ :candidate_id, :tag_id ], unique: true
    add_index :candidate_tags, :tag_id
  end
end
