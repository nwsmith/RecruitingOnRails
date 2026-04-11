class DiaryEntry < ApplicationRecord
  belongs_to :diary_entry_type, optional: true
  belongs_to :user
  belongs_to :candidate

  def summary
    "#{entry_date} - #{diary_entry_type&.name || 'N/A'}"
  end

  def color
    return "black" unless diary_entry_type
    diary_entry_type.positive? ? "green" : diary_entry_type.negative? ? "red" : "black"
  end
end
