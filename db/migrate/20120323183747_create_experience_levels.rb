class CreateExperienceLevels < ActiveRecord::Migration[7.0]
  def up
    create_table :experience_levels do |t|
      t.string :code
      t.string :name
      t.string :description
    end

    change_table :candidates do |t|
      t.references :experience_level
    end

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_candidate_exp_lvls
        FOREIGN KEY (experience_level_id)
        REFERENCES experience_levels(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_candidate_exp_lvls
    SQL

    remove_column :candidates, :experience_level_id

    drop_table :experience_levels
  end

end
