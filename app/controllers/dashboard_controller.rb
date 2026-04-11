class DashboardController < ApplicationController
  RECENT_ACTIVITY_LIMIT = 10

  def index
    if current_user&.staff?
      load_staff_dashboard
      @recent_activities = Activity.recent.limit(RECENT_ACTIVITY_LIMIT).includes(:actor)
    else
      # Non-staff users must not see candidate listings — that was the
      # dashboard enumeration gap. If the user happens to be a candidate
      # themselves (self.candidate-style user_name matching an active
      # application), expose only their own record so they can click
      # through to their application page.
      @self_candidate = Candidate.for_self_user(current_user).first
    end
  end

  private

  def load_staff_dashboard
    @dashboard_data = Hash.new

    headcount_targets = Hash.new
    registries = Registry.all.index_by(&:key)

    # One grouped query instead of N+1: hired headcount per budget.
    hired_counts_by_budget = Candidate.by_status_code("HIRED").group(:associated_budget_id).count

    AssociatedBudget.all.each do |associated_budget|
      budget_headcount_target_key = "team.headcount_target." + associated_budget.code
      budget_headcount_target_reg = registries[budget_headcount_target_key]

      next if budget_headcount_target_reg.nil?

      budget_candidate_count = hired_counts_by_budget[associated_budget.id] || 0

      budget_props = Hash.new
      budget_props[:name] = associated_budget.name
      budget_props[:target] = budget_headcount_target_reg.value.to_i
      budget_props[:current] = budget_candidate_count
      budget_props[:needed] = budget_props[:target] - budget_props[:current]

      headcount_targets[associated_budget.code] = budget_props
    end

    @dashboard_data[:headcount_targets] = headcount_targets.presence

    default_status = registries["dashboard.default_status"]
    @dashboard_data[:candidates_by_status] =
      if default_status.nil?
        Candidate.none
      else
        default_statuses = default_status.value.split(",")
        Candidate.for_table.merge(Candidate.by_status_codes(default_statuses))
      end
  end
end
