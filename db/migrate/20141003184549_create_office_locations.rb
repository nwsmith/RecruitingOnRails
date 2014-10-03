class CreateOfficeLocations < ActiveRecord::Migration
  def up
    create_table :office_locations do |t|
      t.string :code
      t.string :name
      t.string :description
    end

    change_table :candidates do |t|
      t.references :office_location
    end

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_candidate_off_loc
        FOREIGN KEY (office_location_id)
        REFERENCES office_locations(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_candidate_off_loc
    SQL

    remove_column :candidates, :office_location_id

    drop_table :office_locations
  end
end
