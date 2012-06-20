module DashboardHelper
  def candidates_table(*args)
    candidates = args.first
    #opts = args.second || {}

    interview_column_count = 0
    candidates.each {|c| interview_column_count = c.interviews.length if c.interviews.length > interview_column_count}
    code_submission_column_count = 0
    candidates.each {|s| code_submission_column_count = s.code_submissions.length if s.code_submissions.length > code_submission_column_count}

    out = "<table>"
    out += "<tr>"
    out += "<th>Name</th>"
    1.upto(code_submission_column_count) do |i|
      out += "<th>Code Submission #{i}</th>"
    end
    1.upto(interview_column_count) do |i|
      out += "<th>Interview #{i}</th>"
    end
    out += "<th>References?</th>"
    out += "</tr>"
    candidates.each do |candidate|
      out += "<tr>"
      out += "<td>"
      out += link_to(color_span(candidate.experience_level, candidate.name), candidate_path(candidate))
      out += "</td>"
      0.upto(code_submission_column_count-1) do |i|
        out += "<td>"
        out += candidate.code_submissions[i].nil? ? '&nbsp;' : (link_to approved_span(candidate.code_submissions[i]), code_submission_path(candidate.code_submissions[i]))
        out += "</td>"
      end
      0.upto(interview_column_count-1) do |i|
        out += "<td>"
        out += candidate.interviews[i].nil? ? '&nbsp;' : (link_to approved_span(candidate.interviews[i]), interview_path(candidate.interviews[i]))
        out += "</td>"
      end
      out += "<td>"
      out += approved_span(candidate.reference_checks, :text => candidate.reference_checks.length)
      out += "</td>"
      out += "</tr>"
    end
    out += "</table>"
    out.html_safe
  end

  def counts_by_status
    candidates_by_status = Hash.new
    CandidateStatus.all.each {|status| candidates_by_status[status] = 0}
    Candidate.all.each {|candidate| candidates_by_status[candidate.candidate_status] += 1}

    out = "<table>"
    out += "<th>Status</th><th>Count</th>"
    candidates_by_status.each_pair do |k,v|
      out += "<tr><td>#{link_to k.name, :controller => 'candidates', :action => 'list', 'status' => k.code}</td><td>#{v}</td></tr>"  if v > 0
    end
    out += "</table>"
    out.html_safe
  end
end
