class DiaryEntry < ApplicationRecord
  belongs_to :diary_entry_type
  belongs_to :user
  belongs_to :candidate

  def summary
    "#{entry_date} - #{diary_entry_type.name}"
  end

  def color
    (diary_entry_type.positive?) ? 'green' : (diary_entry_type.negative?) ? 'red' : 'black'
  end
end
