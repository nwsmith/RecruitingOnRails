class DashboardController < ApplicationController
  def index
    default_status = Registry.find_by_key('dashboard.default_status')
    @candidates_by_status = Candidate.by_status_code(default_status.value)
  end
end
