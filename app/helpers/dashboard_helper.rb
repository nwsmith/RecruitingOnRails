module DashboardHelper

  def counts_by_status
    candidates_by_status = Hash.new
    CandidateStatus.all.each {|status| candidates_by_status[status] = 0}
    Candidate.all.each {|candidate| candidates_by_status[candidate.candidate_status] = candidates_by_status[candidate.candidate_status].nil? ? 0 : candidates_by_status[candidate.candidate_status] + 1}

    out = '<table>'
    out += '<th>Status</th><th>Count</th>'
    candidates_by_status.each_pair do |k,v|
      out += "<tr><td>#{link_to k.name, :controller => 'candidates', :action => 'list', 'status' => k.code}</td><td>#{v}</td></tr>"  if v > 0
    end
    out += '</table>'
    out.html_safe
  end
end
