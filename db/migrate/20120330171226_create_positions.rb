class CreatePositions < ActiveRecord::Migration[7.0]
  def up
    create_table :positions do |t|
      t.string :code
      t.string :name
      t.string :description

      t.timestamps
    end

    change_table :candidates do |t|
      t.references :position
    end

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_candidate_position
        FOREIGN KEY (position_id)
        REFERENCES positions(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_candidate_position
    SQL

    remove_column :candidates, :position_id

    drop_table :positions
  end
end
