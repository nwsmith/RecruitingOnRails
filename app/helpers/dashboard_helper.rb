module DashboardHelper
  def candidates_by_status_table(*args)
    opts = args.first || {}
    status = opts[:status]

    candidates = Candidate.by_status_code(status)

    candidates.each do |candidate|
      candidate.name
    end

  end
end
