class DashboardController < ApplicationController
  def index
    headcount_target_registry = Registry.find_by_key('team.headcount_target')

    if headcount_target_registry.nil?
      @headcount_target = nil
    else
      @headcount_target = headcount_target_registry.value.to_i
      @hired_count = Candidate.by_status_code('HIRED').length
      @headcount_left = @headcount_target - @hired_count
    end

    default_status = Registry.find_by_key('dashboard.default_status')
    @candidates_by_status = Candidate.by_status_code(default_status.value)
  end
end
