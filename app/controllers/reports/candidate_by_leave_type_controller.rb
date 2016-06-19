class Reports::CandidateByLeaveTypeController < ApplicationController
  def index
  end

  def run
    @table = Reports::ReportTable.new('Leavers By Reason')
    @table.header = ['Reason', 'Count', 'Lame Graphic']

    candidates = Candidate.all

    by_reason = Hash.new

    candidates.each do |candidate|
      next if candidate.leave_reason.nil?
      reason = candidate.leave_reason.name
      by_reason[reason] = 0 if by_reason[reason].nil?
      by_reason[reason] += 1
    end

    by_reason.sort_by {|k,v| -v}.each {|a| @table.rows << [a[0], a[1], "#{'*' * a[1]}"]}
  end
end
