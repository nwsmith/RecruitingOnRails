class AddRejectionCallRequestDate < ActiveRecord::Migration
  def change
    add_column :candidates, :rejection_call_request_date, :date
  end
end
