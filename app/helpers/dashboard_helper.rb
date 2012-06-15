module DashboardHelper
  def candidates_table(*args)
    candidates = args.first
    #opts = args.second || {}

    interview_column_count = 0
    candidates.each {|c| interview_column_count = c.interviews.length if c.interviews.length > interview_column_count}
    code_submission_column_count = 0
    candidates.each {|s| code_submission_column_count = s.code_submissions.length if s.code_submissions.length > code_submission_column_count}

    out = "<table>"
    out += "<th>Name</th>"
    1.upto(code_submission_column_count) do |i|
      out += "<th>Code Submission #{i}</th>"
    end
    1.upto(interview_column_count) do |i|
      out += "<th>Interview #{i}</th>"
    end
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
      out += "</tr>"
    end
    out += "</table>"
    out.html_safe
  end
end
