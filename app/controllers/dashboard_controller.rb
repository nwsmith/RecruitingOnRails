class DashboardController < ApplicationController
  def index
    @dashboard_data = Hash.new

    associated_budgets = AssociatedBudget.all
    headcount_targets = Hash.new



    associated_budgets.each do |associated_budget|
      budget_headcount_target_key = 'team.headcount_target.' + associated_budget.code
      budget_headcount_target_reg = Registry.find_by_key(budget_headcount_target_key)

      budget_candidate_count = Candidate.by_status_code('HIRED').select{|c| c.associated_budget_id.equal?(associated_budget.id)}.size

      unless budget_headcount_target_reg.nil?
        budget_props = Hash.new
        budget_props[:name] = associated_budget.name
        budget_props[:target] = budget_headcount_target_reg.value.to_i
        budget_props[:current] = budget_candidate_count
        budget_props[:needed] = budget_props[:target] - budget_props[:current]

        headcount_targets[associated_budget.code] = budget_props
      end
    end

    if headcount_targets.empty?
      @dashboard_data[:headcount_targets] = nil
    else
      @dashboard_data[:headcount_targets] = headcount_targets
    end

    default_status = Registry.find_by_key('dashboard.default_status')
    @dashboard_data[:candidates_by_status] = Candidate.by_status_code(default_status.value)
  end
end
