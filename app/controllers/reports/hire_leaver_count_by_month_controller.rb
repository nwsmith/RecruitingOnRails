class Reports::HireLeaverCountByMonthController < ApplicationController
  def index
  end

  def run
    @table = Reports::ReportTable.new('Hire Count By Month')
    @table.header = ['Month', 'Count', 'Lame Graphic']

    @table1 = Reports::ReportTable.new('Leaver Count By Month')
    @table1.header = ['Month', 'Count', 'Lame Graphic']

    period_info = Reports::PeriodInfo.new

    period_info.add_candidates(Candidate.by_status_code('HIRED'))
    period_info.add_candidates(Candidate.by_status_code('FIRED'))
    period_info.add_candidates(Candidate.by_status_code('QUIT'))

    hires_by_month = {}
    leavers_by_month = {}

    1.upto(12) { |m| hires_by_month[m] = 0; leavers_by_month[m] = 0 }

    period_info.hired_list_ignore_left.each { |c| hires_by_month[c.start_date.month] += 1 }
    period_info.left_list.each { |c| leavers_by_month[c.start_date.month] += 1 }

    hires_by_month.keys.sort.each do |m|
      @table.rows << [Date.new(2016, m).strftime('%b'), hires_by_month[m], "#{'*' * hires_by_month[m]}"]
    end

    leavers_by_month.keys.sort.each do |m|
      @table1.rows << [Date.new(2016, m).strftime('%b'), leavers_by_month[m], "#{'*' * leavers_by_month[m]}"]
    end
  end
end
