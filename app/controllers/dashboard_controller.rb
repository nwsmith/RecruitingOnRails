class DashboardController < ApplicationController
  def index
    @dashboard_data = Hash.new

    headcount_target_registry = Registry.find_by_key('team.headcount_target')

    if headcount_target_registry.nil?
      @dashboard_data[:headcount_target] = nil
    else
      @dashboard_data[:headcount_target] = headcount_target_registry.value.to_i
      @dashboard_data[:hired_count] = Candidate.by_status_code('HIRED').length
      @dashboard_data[:headcount_left] = @dashboard_data[:headcount_target] - @dashboard_data[:hired_count]
    end

    default_status = Registry.find_by_key('dashboard.default_status')
    @dashboard_data[:candidates_by_status] = Candidate.by_status_code(default_status.value)
  end
end
