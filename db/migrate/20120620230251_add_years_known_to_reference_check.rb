class AddYearsKnownToReferenceCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :reference_checks, :years_known, :integer
  end
end
