class CreateGenders < ActiveRecord::Migration[7.0]
  def up
    create_table :genders do |t|
      t.string :code
      t.string :name
      t.string :description
    end

    change_table :candidates do |t|
      t.references :genders
    end

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_genders
        FOREIGN KEY (genders_id)
        REFERENCES genders(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_genders
    SQL

    remove_column :candidates, :genders_id

    drop_table :genders
  end
end
