class Reports::CandidatesBySourceController < ApplicationController
  def index
  end

  def run
    @table = Reports::ReportTable.new('Candidates By Source')
    @table.header = ['Source', 'Count', 'Lame Graphic']

    status_list = get_list_from_params(params, :status)
    status_list << 'HIRED' if status_list.empty?

    candidates = Array.new
    status_list.each do |s|
      candidates << Candidate.by_status_code(s)
    end
    candidates = candidates.flatten

    by_source = Hash.new

    candidates.each do |candidate|
      source = candidate.candidate_source.nil? ? 'N/A' : candidate.candidate_source.name
      by_source[source] = 0 if by_source[source].nil?
      by_source[source] += 1
    end

    by_source.sort_by{|k,v| -v}.each {|a| @table.rows << [a[0], a[1],"#{'*' * a[1]}"]}

  end
end
