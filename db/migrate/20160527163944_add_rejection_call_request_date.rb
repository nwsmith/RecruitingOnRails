class AddRejectionCallRequestDate < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :rejection_call_request_date, :date
  end
end
