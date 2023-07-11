class CreateEducationLevels < ActiveRecord::Migration[7.0]
  def up
    create_table :education_levels do |t|
      t.string :code
      t.string :name
      t.string :description

      t.timestamps
    end

    change_table :candidates do |t|
      t.references :education_level
    end

    execute <<-SQL
     ALTER TABLE candidates
       ADD CONSTRAINT fk_candidate_edu_lvl
       FOREIGN KEY (education_level_id)
       REFERENCES education_levels(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_candidate_edu_lvl
    SQL

    remove_column :candidates, :education_level_id

    drop_table :education_levels
  end
end
