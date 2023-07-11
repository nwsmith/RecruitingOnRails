class AddSalaryRangeToCandidate < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :salary_range, :string
  end
end
