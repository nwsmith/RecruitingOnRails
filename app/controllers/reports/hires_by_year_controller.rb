class Reports::HiresByYearController < ApplicationController
  def index
  end

  def run
    @table = Reports::ReportTable.new('Hires By Year')
    @table.header = %w(Year Hires)

    @table1 = Reports::ReportTable.new('Leavers By Year')
    @table1.header = %w(Year Hires)

    period_info = Reports::PeriodInfo.new
    Candidate.all.each {|c| period_info.add_candidate(c) unless c.start_date.nil?}
    period_info.year_info_map.values.sort {|a,b| a.year <=> b.year}.each do |year_info|
      dev_list = []
      year_info.still_here.sort_by{|d| d.start_date}.each {|d| dev_list << "#{d.first_name} #{d.last_name} (#{d.start_date.strftime('%b')}, #{d.tenure_in_years})"}
      @table.rows << [year_info.year, dev_list.join(',')]

      dev_list1 = []
      year_info.left_in_year.sort_by{|d| d.end_date}.each {|d| dev_list1 << "#{d.first_name} #{d.last_name} (#{d.end_date.strftime('%b')}, #{d.tenure_in_years})"}
      @table1.rows << [year_info.year, dev_list1.join(',')]
    end
  end
end