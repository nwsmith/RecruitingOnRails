class AddRejectionNotificationDate < ActiveRecord::Migration
  def change
    add_column :candidates, :rejection_notification_date, :date
  end
end
