class AddReferenceFields < ActiveRecord::Migration[7.0]
  def change
    add_column :reference_checks, :title, :string
    add_column :reference_checks, :company, :string
    add_column :reference_checks, :relationship, :string
  end
end
