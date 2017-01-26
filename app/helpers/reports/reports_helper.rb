module Reports::ReportsHelper
  def render_report_tables(report_tables)
    out = ''
    report_tables.each {|report_table| out += "#{render_report_table(report_table)}<br/>"}
    out.html_safe
  end

  def render_report_table(report_table)
    out = ''
    out += "<h1>#{report_table.title}</h1>\n"
    out += "<table>\n"
    out += '<tr>'
    report_table.header.each do |h|
      out += "<th>#{h}</th>"
    end
    out += "</tr>\n"
    report_table.rows.each do |row|
      out += '<tr>'
      row.each do |cell|
        out += "<td>#{cell}</td>"
      end
      out += "</tr>\n"
    end
    out += "</table>\n"
    out.html_safe
  end
end