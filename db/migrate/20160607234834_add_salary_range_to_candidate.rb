class AddSalaryRangeToCandidate < ActiveRecord::Migration
  def change
    add_column :candidates, :salary_range, :string
  end
end
