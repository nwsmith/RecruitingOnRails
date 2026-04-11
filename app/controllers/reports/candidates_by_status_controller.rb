class Reports::CandidatesByStatusController < ApplicationController
  before_action :check_staff

  def index
  end

  def run
    @table = Reports::ReportTable.new('Candidates By Status')
    @table.header = %w(Status Count)

    # Two queries instead of N+1: one grouped count, one status lookup.
    counts_by_status_id = Candidate.where.not(candidate_status_id: nil).group(:candidate_status_id).count
    statuses_by_id = CandidateStatus.where(id: counts_by_status_id.keys).index_by(&:id)

    counts_by_status_id.each do |status_id, count|
      status = statuses_by_id[status_id]
      next if status.nil?
      @table.rows << [view_context.link_to(status.name, controller: '/candidates', action: 'list', status: status.code), count]
    end
  end
end
