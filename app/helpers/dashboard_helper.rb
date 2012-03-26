module DashboardHelper
  def candidates_table(*args)
    candidates = args.first
    #opts = args.second || {}

    out = "<table>"
    out += "<th>Name</th>"
    candidates.each do |candidate|
      out += "<tr>"
      out += "<td>"
      out += link_to candidate.name, candidate_path(candidate)
      out += "</td>"
      out += "</tr>"
    end
    out += "</table>"
    out.html_safe
  end
end
