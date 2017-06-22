class Reports::CandidatesByStatusController < ApplicationController
  def index
  end

  def run
    @table = Reports::ReportTable.new('Candidates By Status')
    @table.header = %w(Status Count)
    
    candidates_by_status = Hash.new
    CandidateStatus.all.each {|status| candidates_by_status[status] = 0}
    Candidate.all.each {|candidate| candidates_by_status[candidate.candidate_status] = candidates_by_status[candidate.candidate_status].nil? ? 0 : candidates_by_status[candidate.candidate_status] + 1}

    candidates_by_status.delete nil

    candidates_by_status.each_pair{|k,v| @table.rows << ["#{view_context.link_to k.name, :controller => '/candidates', :action => 'list', 'status' => k.code}", v]}
  end
end
