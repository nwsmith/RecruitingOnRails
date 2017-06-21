class Reports::TeamByYearController < ApplicationController
  def index
  end

  def run
    candidates = Candidate.by_status_code('FIRED')
    candidates << Candidate.by_status_code('HIRED')
    candidates << Candidate.by_status_code('QUIT')
    candidates = candidates.flatten

    period_info = Reports::PeriodInfo.new
    period_info.add_candidates(candidates)

    @table = Reports::ReportTable.new('Team By Year')

    @table.header = ['Year', 'Hired', 'Here', 'Left', 'Net', 'Cum', 'Sad TO', 'Med TO', 'Hap TO', 'Vol. TO', 'Tot. TO', 'AVG', 'Med']

    period_info.year_info_map.values.sort{|a,b| a.year <=> b.year}.each do |year_info|

      year = year_info.year
      hired = year_info.started_in_year.size

      report_date = (year == Date.today.year) ? Date.today : Date.new(year, 12, 31)

      row = Array.new
      row << year
      row << hired
      row << year_info.still_here.size
      row << year_info.left_in_year.size
      row << period_info.net_gain(report_date)
      row << period_info.size(report_date)
      row << period_info.sad_turnover(report_date).round(2)
      row << period_info.med_turnover(report_date).round(2)
      row << period_info.happy_turnover(report_date).round(2)
      row << period_info.voluntary_turnover(report_date).round(2)
      row << period_info.turnover(report_date).round(2)
      row << period_info.average_tenure(report_date).round(2)
      row << period_info.median_tenure(report_date).round(2)

      @table.rows << row
    end

  end
end
