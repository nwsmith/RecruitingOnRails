class AddMoreCandidateDates < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :offer_date, :date
    add_column :candidates, :offer_accept_date, :date
    add_column :candidates, :offer_turndown_date, :date
    add_column :candidates, :start_date, :date
    add_column :candidates, :fire_date, :date
    add_column :candidates, :quit_date, :date
    add_column :candidates, :end_date, :date
  end
end
