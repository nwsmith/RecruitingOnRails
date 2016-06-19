class CreateLeaveReasons < ActiveRecord::Migration
  def up
    create_table :leave_reasons do |t|
      t.string :code
      t.string :name
      t.string :description
    end

    change_table :candidates do |t|
      t.references :leave_reason
    end

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_leave_reason
        FOREIGN KEY (leave_reason_id)
        REFERENCES leave_reasons(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_leave_reason
    SQL

    remove_column :candidates, :leave_reason_id

    drop_table :leave_reasons
  end
end
