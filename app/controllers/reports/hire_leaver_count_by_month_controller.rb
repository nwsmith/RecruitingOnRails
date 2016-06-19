class Reports::HireLeaverCountByMonthController < ApplicationController
  def index
  end

  def run
    @table = Reports::ReportTable.new('Hire Count By Month')
    @table.header = ['Month', 'Count', 'Lame Graphic']

    @table1 = Reports::ReportTable.new('Leaver Count By Month')
    @table1.header = ['Month', 'Count', 'Lame Graphic']

    period_info = Reports::PeriodInfo.new
    Candidate.all.each { |c| period_info.add_candidate(c) unless c.start_date.nil? }

    hires_by_month = {}
    leavers_by_month = {}

    1.upto(12) { |m| hires_by_month[m] = 0; leavers_by_month[m] = 0 }

    period_info.hired_list_ignore_left.each { |c| hires_by_month[c.start_date.month] += 1 }
    period_info.left_list.each { |c| leavers_by_month[c.start_date.month] += 1 }

    1.upto(12) do |m|
      d = Date.new(2016, m).strftime('%b')

      @table.rows << [d, hires_by_month[m], "#{'*' * hires_by_month[m]}"]
      @table1.rows << [d, leavers_by_month[m], "#{'*' * leavers_by_month[m]}"]
    end
  end
end
