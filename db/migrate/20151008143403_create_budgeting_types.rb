class CreateBudgetingTypes < ActiveRecord::Migration
  def up
    create_table :budgeting_types do |t|
      t.string :code
      t.string :name
      t.string :description
    end

    BudgetingType.create({:code => 'NEW', :name => 'Net New'})
    BudgetingType.create({:code => 'REPLACE', :name => 'Replacement'})

    change_table :candidates do |t|
      t.references :budgeting_type
    end

    add_column :candidates, :replacement_for, :string

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_budgeting_type
        FOREIGN KEY (budgeting_type_id)
        REFERENCES budgeting_types(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_budgeting_type
    SQL

    remove_column :candidates, :budgeting_type_id
    remove_column :candidates, :replacement_for

    drop_table :budgeting_types
  end
end
