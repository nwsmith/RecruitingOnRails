require 'test_helper'

# Coverage for ReportsController (the shell landing page) and the 8
# nested controllers under app/controllers/reports/. Each nested
# controller has the same shape: an `index` action that just renders
# a form, and a `run` action that runs the report query and renders
# results. All 9 controllers are check_staff-gated by 2327813.
#
# Lives under test/integration rather than test/controllers because it
# spans multiple controllers and exercises both the auth gate and the
# report rendering paths in one cohesive sweep.
class ReportsControllersTest < ActionDispatch::IntegrationTest
  setup do
    # Minimum data the queries actually look at: candidates with HIRED,
    # FIRED, and QUIT statuses so the period-info / by-status reports
    # have something non-empty to walk. Without these the reports still
    # render — they just produce empty tables — which is fine for the
    # smoke-test purpose here.
    @hired_status  = CandidateStatus.create!(code: 'HIRED',  name: 'Hired')
    @fired_status  = CandidateStatus.create!(code: 'FIRED',  name: 'Fired')
    @quit_status   = CandidateStatus.create!(code: 'QUIT',   name: 'Quit')

    Candidate.create!(
      first_name: 'Hired', last_name: 'Person',
      candidate_status: @hired_status,
      application_date: Date.today - 200,
      first_contact_date: Date.today - 190,
      start_date: Date.today - 100
    )
    Candidate.create!(
      first_name: 'Fired', last_name: 'Person',
      candidate_status: @fired_status,
      application_date: Date.today - 400,
      start_date: Date.today - 300,
      fire_date: Date.today - 50
    )
  end


  # ----- ReportsController shell -----

  test 'unauthenticated reports index redirects to login' do
    get reports_index_path
    assert_redirected_to root_path
  end

  test 'regular user cannot reach reports landing' do
    login_as 'regular'
    get reports_index_path
    assert_redirected_to dashboard_path
  end

  test 'admin can reach reports landing' do
    login_as 'admin'
    get reports_index_path
    assert_response :success
  end

  test 'manager can reach reports landing' do
    login_as 'manager'
    get reports_index_path
    assert_response :success
  end

  test 'hr can reach reports landing' do
    login_as 'hruser'
    get reports_index_path
    assert_response :success
  end

  # ----- The 8 nested report controllers, parameterized -----
  #
  # Each entry: [route helper for index, route helper for run].
  # We hit each in turn under three identities:
  #   - unauthenticated → redirected to login
  #   - regular        → redirected to dashboard (check_staff)
  #   - admin          → :success
  REPORT_PAIRS = %i[
    reports_candidates_by_status_index_path  reports_candidates_by_status_run_path
    reports_budget_report_index_path         reports_budget_report_run_path
    reports_hire_leaver_count_by_month_index_path reports_hire_leaver_count_by_month_run_path
    reports_hires_by_year_index_path         reports_hires_by_year_run_path
    reports_candidate_by_leave_type_index_path reports_candidate_by_leave_type_run_path
    reports_team_by_year_index_path          reports_team_by_year_run_path
    reports_candidates_by_source_index_path  reports_candidates_by_source_run_path
    reports_cycle_time_report_index_path     reports_cycle_time_report_run_path
  ].each_slice(2).to_a.freeze

  REPORT_PAIRS.each do |index_helper, run_helper|
    name = index_helper.to_s.sub('reports_', '').sub('_index_path', '')

    define_method("test_unauthenticated_cannot_reach_#{name}_index") do
      get send(index_helper)
      assert_redirected_to root_path
    end

    define_method("test_unauthenticated_cannot_reach_#{name}_run") do
      get send(run_helper)
      assert_redirected_to root_path
    end

    define_method("test_regular_user_cannot_reach_#{name}_index") do
      login_as 'regular'
      get send(index_helper)
      assert_redirected_to dashboard_path
    end

    define_method("test_regular_user_cannot_reach_#{name}_run") do
      login_as 'regular'
      get send(run_helper)
      assert_redirected_to dashboard_path
    end

    define_method("test_admin_can_reach_#{name}_index") do
      login_as 'admin'
      get send(index_helper)
      assert_response :success
    end

    define_method("test_admin_can_run_#{name}") do
      login_as 'admin'
      get send(run_helper)
      assert_response :success
    end
  end
end
