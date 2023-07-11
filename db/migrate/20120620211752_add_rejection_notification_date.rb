class AddRejectionNotificationDate < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :rejection_notification_date, :date
  end
end
