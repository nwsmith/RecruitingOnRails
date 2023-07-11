class CreateSchools < ActiveRecord::Migration[7.0]
  def up
    create_table :schools do |t|
      t.string :code
      t.string :name
      t.string :description

      t.timestamps
    end

    change_table :candidates do |t|
      t.references :school
    end

    execute <<-SQL
     ALTER TABLE candidates
       ADD CONSTRAINT fk_candidate_school
       FOREIGN KEY (school_id)
       REFERENCES schools(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_candidate_school
    SQL

    remove_column :candidates, :school_id

    drop_table :schools
  end
end
