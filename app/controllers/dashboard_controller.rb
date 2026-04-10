class DashboardController < ApplicationController
  def index
    @dashboard_data = Hash.new

    headcount_targets = Hash.new
    registries = Registry.all.index_by(&:key)
    hired_candidates = Candidate.by_status_code('HIRED')

    AssociatedBudget.all.each do |associated_budget|
      budget_headcount_target_key = 'team.headcount_target.' + associated_budget.code
      budget_headcount_target_reg = registries[budget_headcount_target_key]

      next if budget_headcount_target_reg.nil?

      budget_candidate_count = hired_candidates.count { |c| c.associated_budget_id == associated_budget.id }

      budget_props = Hash.new
      budget_props[:name] = associated_budget.name
      budget_props[:target] = budget_headcount_target_reg.value.to_i
      budget_props[:current] = budget_candidate_count
      budget_props[:needed] = budget_props[:target] - budget_props[:current]

      headcount_targets[associated_budget.code] = budget_props
    end

    @dashboard_data[:headcount_targets] = headcount_targets.presence

    @dashboard_data[:candidates_by_status] = Array.new

    default_status = registries['dashboard.default_status']
    if !default_status.nil?
      default_statuses = default_status.value.split ','
      default_statuses.each {|status| @dashboard_data[:candidates_by_status] << Candidate.by_status_code(status)}
    end

    @dashboard_data[:candidates_by_status] = @dashboard_data[:candidates_by_status].flatten
  end
end
