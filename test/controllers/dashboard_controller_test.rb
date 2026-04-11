require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pending_status = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @hired_status   = CandidateStatus.create!(code: 'HIRED', name: 'Hired')

    # A candidate with a unique name that appears on the staff dashboard's
    # candidates_table. The dashboard's "candidates_by_status" pulls from
    # Registry['dashboard.default_status'] — create that registry entry
    # pointing at HIRED so there's something to display.
    @visible_candidate = Candidate.create!(
      first_name: 'UniqueVisible',
      last_name: 'DashboardRow',
      candidate_status: @hired_status
    )
    Registry.create!(key: 'dashboard.default_status', value: 'HIRED')

    # A candidate whose name matches the self.candidate fixture's user_name.
    # The fixture user_name is "self.candidate", first_name: Self, last_name:
    # Candidate — Candidate#for_self_user does a LOWER(first) = LOWER(last)
    # match, so this row is what a self.candidate-style user should see.
    @self_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @pending_status
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  # ----- auth -----

  test 'unauthenticated request to dashboard redirects to login' do
    get dashboard_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  # ----- staff branch: admin / manager / hr see the candidates_table -----

  test 'admin sees the full candidates_table on the dashboard' do
    login_as 'admin'
    get dashboard_path
    assert_response :success
    assert_match 'UniqueVisible', response.body
    assert_match 'New Candidate', response.body
  end

  test 'manager sees the full candidates_table on the dashboard' do
    login_as 'manager'
    get dashboard_path
    assert_response :success
    assert_match 'UniqueVisible', response.body
  end

  test 'hr sees the full candidates_table on the dashboard' do
    login_as 'hruser'
    get dashboard_path
    assert_response :success
    assert_match 'UniqueVisible', response.body
  end

  # ----- non-staff branch: enumeration gap is closed -----

  test 'regular user does NOT see any candidate names on the dashboard' do
    login_as 'regular'
    get dashboard_path
    assert_response :success

    # The enumeration gap: a regular user must NOT see candidate names on the
    # dashboard. Before this fix, candidates_table was rendered unconditionally.
    assert_no_match 'UniqueVisible',  response.body
    assert_no_match 'DashboardRow',   response.body

    # The "New Candidate" link is a staff affordance and must be hidden too.
    assert_no_match 'New Candidate', response.body

    # The friendly fallback should be visible instead.
    assert_match 'recruiting staff', response.body
  end

  test 'regular user dashboard does not render the experience legend' do
    # The legend is staff context; non-staff shouldn't see any of the color
    # codes either. This is a light regression that also guards against the
    # candidates_table helper being accidentally reintroduced via the legend.
    login_as 'regular'
    get dashboard_path
    assert_no_match 'Experience Legend', response.body
  end

  # ----- self-candidate branch: sees own application, not others' -----

  test 'self candidate user sees their own application link, not the table' do
    login_as 'self.candidate'
    get dashboard_path
    assert_response :success

    # Their own application should be linked.
    assert_match 'View your application', response.body
    assert_match candidate_path(@self_candidate), response.body
    # Status label should be displayed.
    assert_match 'Pending', response.body

    # They must NOT see the unrelated visible candidate, the New Candidate
    # link, or the experience legend.
    assert_no_match 'UniqueVisible',    response.body
    assert_no_match 'New Candidate',    response.body
    assert_no_match 'Experience Legend', response.body
  end

  test 'self candidate user stops seeing the application link after hire' do
    # Once the candidate is no longer PEND/VERBAL, Candidate.for_self_user
    # returns Candidate.none and the dashboard falls back to the generic
    # "contact your administrator" message.
    @self_candidate.update!(candidate_status: @hired_status)

    login_as 'self.candidate'
    get dashboard_path
    assert_response :success

    assert_no_match 'View your application', response.body
    assert_match 'recruiting staff', response.body
  end

  test 'self candidate user does not see other candidates via for_self_user lookup' do
    # Create a second Pending candidate whose name does NOT match the
    # self.candidate fixture. The lookup is name-based, so the self.candidate
    # user must only ever see the one matching row.
    other_pending = Candidate.create!(
      first_name: 'Someone',
      last_name: 'Else',
      candidate_status: @pending_status
    )

    login_as 'self.candidate'
    get dashboard_path
    assert_response :success

    assert_no_match other_pending.name, response.body
  end
end
