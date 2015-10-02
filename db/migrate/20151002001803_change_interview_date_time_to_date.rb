class ChangeInterviewDateTimeToDate < ActiveRecord::Migration
  def up
    times = Hash.new
    Interview.all.each { |i| times[i.id] = i.meeting_time }

    change_column :interviews, :meeting_time, :date

    Interview.all.each do |i|
      time = times[i.id]
      i.meeting_time = Date.new(time.year, time.month, time.mday) unless time.nil?
      i.save
    end
  end

  def down
    dates = Hash.new
    Interview.all.each { |i| dates[i.id] = i.meeting_time }

    change_column :interviews, :meeting_time, :datetime

    Interview.all.each do |i|
      date = dates[i.id]
      i.meeting_time = DateTime.new(date.year, date.month, date.mday) unless date.nil?
      i.save
    end
  end
end
