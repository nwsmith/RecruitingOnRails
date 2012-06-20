class AddYearsKnownToReferenceCheck < ActiveRecord::Migration
  def change
    add_column :reference_checks, :years_known, :integer
  end
end
