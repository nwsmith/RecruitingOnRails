class Reports::CandidateByLeaveTypeController < ApplicationController
  def index
  end

  def run
    @report = Array.new
    candidates = Candidate.all

    by_reason = Hash.new

    candidates.each do |candidate|
      next if candidate.leave_reason.nil?
      reason = candidate.leave_reason.name
      by_reason[reason] = 0 if by_reason[reason].nil?
      by_reason[reason] += 1
    end

    @header = ['Reason', 'Count', 'Lame Graphic']
    by_reason.sort_by {|k,v| -v}.each {|a| @report << [a[0], a[1], "#{'*' * a[1]}"]}
  end
end
