class CreateAssociatedBudgets < ActiveRecord::Migration[7.0]
  def up
    create_table :associated_budgets do |t|
      t.string :code
      t.string :name
      t.string :description
      t.boolean :active
    end

    AssociatedBudget.create({:code => 'EXST', :name => 'Existing', :active => true})
    AssociatedBudget.create({:code => 'MSSB', :name => 'Morgan Stanley', :active => true})

    change_table :candidates do |t|
      t.references :associated_budget
    end

    execute <<-SQL
      ALTER TABLE candidates
        ADD CONSTRAINT fk_associated_budget
        FOREIGN KEY (associated_budget_id)
        REFERENCES associated_budgets(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE candidates
        DROP FOREIGN KEY fk_associated_budget
    SQL

    remove_column :candidates, :associated_budgets_id

    drop_table :associated_budgets
  end
end
