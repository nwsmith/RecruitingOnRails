require 'test_helper'

class CandidatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pending_status = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @hired_status   = CandidateStatus.create!(code: 'HIRED', name: 'Hired')

    # The self_candidate_user fixture is named "Self Candidate" so that
    # Candidate#username ("self.candidate") matches its user_name. The auth
    # rule allows a user to view their own application while it's pending.
    @self_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @pending_status
    )

    @other_candidate = Candidate.create!(
      first_name: 'Someone',
      last_name: 'Else',
      candidate_status: @hired_status
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  # ----- show: privileged users -----

  test 'admin can view any candidate' do
    login_as 'admin'
    get candidate_path(@other_candidate)
    assert_response :success
  end

  test 'manager can view any candidate' do
    login_as 'manager'
    get candidate_path(@other_candidate)
    assert_response :success
  end

  test 'hr can view any candidate' do
    login_as 'hruser'
    get candidate_path(@other_candidate)
    assert_response :success
  end

  # ----- show: regression tests for the auth bypass fix -----

  test 'regular user cannot view another candidate via show' do
    login_as 'regular'
    get candidate_path(@other_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'user can view their own candidate while pending' do
    login_as 'self.candidate'
    get candidate_path(@self_candidate)
    assert_response :success
  end

  test 'user cannot view their own candidate after hire' do
    login_as 'self.candidate'
    @self_candidate.update_column(:candidate_status_id, @hired_status.id)
    get candidate_path(@self_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'user cannot view someone else even with matching pending status' do
    login_as 'self.candidate'
    get candidate_path(@other_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  # ----- edit / update / destroy: must enforce the same rule -----

  test 'regular user cannot edit another candidate' do
    login_as 'regular'
    get edit_candidate_path(@other_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update another candidate' do
    login_as 'regular'
    patch candidate_path(@other_candidate), params: { candidate: { first_name: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Someone', @other_candidate.reload.first_name
  end

  test 'regular user cannot destroy another candidate' do
    login_as 'regular'
    assert_no_difference -> { Candidate.count } do
      delete candidate_path(@other_candidate)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  # ----- output safety -----

  test 'show escapes html in candidate name' do
    xss = Candidate.create!(
      first_name: '<script>alert(1)</script>',
      last_name: 'Doe',
      candidate_status: @hired_status
    )
    login_as 'admin'
    get candidate_path(xss)
    assert_response :success
    assert_no_match '<script>alert(1)</script>', response.body
    assert_match '&lt;script&gt;alert(1)&lt;/script&gt;', response.body
  end

  test 'json show does not include unescaped script tags' do
    xss = Candidate.create!(
      first_name: '<script>alert(1)</script>',
      last_name: 'Doe',
      candidate_status: @hired_status
    )
    login_as 'admin'
    get candidate_path(xss, format: :json)
    assert_response :success
    # The JSON encoder must not emit a literal closing </script> tag.
    assert_no_match %r{</script>}, response.body
  end

  # ----- collection actions: timeline + events -----
  #
  # `timeline` was rewritten on 2026-04-10 to use vis-timeline instead of the
  # retired SIMILE Timeline widget. The new view fetches its data from
  # `events.json`, so these tests cover the view/action pair.

  test 'timeline renders for admin with default status' do
    login_as 'admin'
    get timeline_candidates_path
    assert_response :success
    # The new vis-timeline container must be present in the HTML.
    assert_match 'id="my-timeline"', response.body
  end

  test 'timeline accepts an explicit status filter' do
    login_as 'admin'
    get timeline_candidates_path(status: 'PEND,HIRED')
    assert_response :success
  end

  test 'events json returns only candidates with start_date set' do
    # Without a start_date the candidate should be excluded from the timeline.
    Candidate.create!(
      first_name: 'No',
      last_name: 'StartDate',
      candidate_status: @hired_status
    )
    with_start = Candidate.create!(
      first_name: 'Has',
      last_name: 'StartDate',
      candidate_status: @hired_status,
      start_date: Date.new(2024, 1, 15)
    )

    login_as 'admin'
    get events_candidates_path(format: :json)
    assert_response :success

    body = JSON.parse(response.body)
    assert body.key?('events'), "expected events key in #{body.inspect}"
    titles = body['events'].map { |e| e['title'] }
    assert_includes titles, with_start.name
    refute_includes titles, 'No StartDate'
  end

  test 'events json fills end date with today when end_date is nil' do
    still_employed = Candidate.create!(
      first_name: 'Still',
      last_name: 'Employed',
      candidate_status: @hired_status,
      start_date: Date.new(2024, 1, 15)
    )

    login_as 'admin'
    get events_candidates_path(format: :json)
    assert_response :success

    body = JSON.parse(response.body)
    row = body['events'].find { |e| e['title'] == still_employed.name }
    assert row, 'expected the Still Employed candidate in events'
    assert_equal Date.today.to_s, row['end']
  end

  test 'events json sorts newest start date first' do
    older = Candidate.create!(
      first_name: 'Older',
      last_name: 'Hire',
      candidate_status: @hired_status,
      start_date: Date.new(2020, 6, 1),
      end_date: Date.new(2021, 6, 1)
    )
    newer = Candidate.create!(
      first_name: 'Newer',
      last_name: 'Hire',
      candidate_status: @hired_status,
      start_date: Date.new(2024, 6, 1),
      end_date: Date.new(2025, 6, 1)
    )

    login_as 'admin'
    get events_candidates_path(format: :json)
    assert_response :success

    body = JSON.parse(response.body)
    titles = body['events'].map { |e| e['title'] }
    older_idx = titles.index(older.name)
    newer_idx = titles.index(newer.name)
    assert newer_idx, 'expected Newer Hire in events'
    assert older_idx, 'expected Older Hire in events'
    assert newer_idx < older_idx, 'expected newest start_date to sort first'
  end

  # ----- collection actions: search -----
  #
  # Search was hardened in commit 1b2e15f to (a) escape LIKE wildcards and (b)
  # accept both "first last" and "last first" orderings. These tests guard both.

  test 'search with empty query returns no rows' do
    Candidate.create!(
      first_name: 'Findable',
      last_name: 'Person',
      candidate_status: @hired_status
    )
    login_as 'admin'
    get search_candidates_path(q: '')
    assert_response :success
    # The `list` view is rendered; the target candidate must not appear because
    # an empty query maps to Candidate.none.
    assert_no_match 'Findable', response.body
  end

  test 'search matches a single token against first or last name' do
    Candidate.create!(
      first_name: 'Uniquefirst',
      last_name: 'Lastname',
      candidate_status: @hired_status
    )
    login_as 'admin'
    get search_candidates_path(q: 'Uniquefirst')
    assert_response :success
    assert_match 'Uniquefirst', response.body
  end

  test 'search matches a two token query in both orderings' do
    Candidate.create!(
      first_name: 'Forward',
      last_name: 'Match',
      candidate_status: @hired_status
    )
    login_as 'admin'

    get search_candidates_path(q: 'Forward Match')
    assert_response :success
    assert_match 'Forward', response.body

    get search_candidates_path(q: 'Match Forward')
    assert_response :success
    assert_match 'Forward', response.body
  end

  test 'search escapes LIKE wildcards so percent cannot widen the match' do
    # A candidate whose first name does NOT contain "Foo" but would be matched
    # if `%` in the query were treated as a wildcard.
    Candidate.create!(
      first_name: 'Unrelated',
      last_name: 'Candidate',
      candidate_status: @hired_status
    )
    login_as 'admin'
    # Raw percent in the query would, pre-fix, turn into LIKE '%%%' and match
    # every row. After escape_like it should be a literal percent and match
    # nothing.
    get search_candidates_path(q: '%')
    assert_response :success
    assert_no_match 'Unrelated', response.body
  end

  # ----- collection-action staff gate -----
  #
  # The dashboard enumeration fix closed the candidates_table leak on the
  # dashboard; these tests guard the matching controller-side gate that
  # keeps regular / self.candidate users from bypassing the dashboard and
  # hitting the routes directly. Per-record actions (show/edit/update/
  # destroy) keep the check_candidate_access helper so self.candidate can
  # still view their own pending record.

  test 'regular user cannot list candidates' do
    login_as 'regular'
    get candidates_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot hit the list collection action' do
    login_as 'regular'
    get list_candidates_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot hit the timeline collection action' do
    login_as 'regular'
    get timeline_candidates_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot hit the events collection action' do
    login_as 'regular'
    get events_candidates_path(format: :json)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot hit the calendar collection action' do
    login_as 'regular'
    get calendar_candidates_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot search candidates' do
    login_as 'regular'
    get search_candidates_path(q: 'anything')
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot open the new candidate form' do
    login_as 'regular'
    get new_candidate_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot create a candidate' do
    login_as 'regular'
    assert_no_difference -> { Candidate.count } do
      post candidates_path, params: {
        candidate: {
          first_name: 'Intruder',
          last_name: 'Persona',
          candidate_status_id: @hired_status.id
        }
      }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'self candidate user cannot enumerate others via index' do
    login_as 'self.candidate'
    get candidates_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'self candidate user cannot hit the timeline either' do
    login_as 'self.candidate'
    get timeline_candidates_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'self candidate user can still view their own pending candidate' do
    # Regression: the new before_action :check_staff must only apply to
    # collection actions. Per-record :show must keep the check_candidate_access
    # branch so self.candidate can reach their own application while pending.
    login_as 'self.candidate'
    get candidate_path(@self_candidate)
    assert_response :success
  end

  test 'hr can still hit all collection actions after the gate' do
    login_as 'hruser'

    get candidates_path
    assert_response :success

    get list_candidates_path
    assert_response :success

    get timeline_candidates_path
    assert_response :success

    get events_candidates_path(format: :json)
    assert_response :success

    get search_candidates_path(q: 'x')
    assert_response :success

    get new_candidate_path
    assert_response :success
  end

  # ----- FK-path self-candidate show (2026-04-11) -----
  #
  # Before the user_id FK, check_candidate_access relied exclusively on
  # `current_user.user_name == candidate.username` ("first.last") to decide
  # whether a self-candidate user could view their own record. That broke
  # for any user whose user_name didn't match the convention. The FK path
  # fixes it: users(:regular) has user_name "regular", which will never
  # match by name.

  test 'regular user with linked pending candidate can view their own candidate via show' do
    linked_candidate = Candidate.create!(
      first_name: 'Renamed',
      last_name: 'Person',
      candidate_status: @pending_status,
      user: users(:regular)
    )
    login_as 'regular'
    get candidate_path(linked_candidate)
    assert_response :success
  end

  test 'regular user with linked hired candidate cannot view their own candidate (status closed)' do
    linked_candidate = Candidate.create!(
      first_name: 'Post',
      last_name: 'Hire',
      candidate_status: @hired_status,
      user: users(:regular)
    )
    login_as 'regular'
    get candidate_path(linked_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view a different users linked candidate' do
    other_users_candidate = Candidate.create!(
      first_name: 'Someone',
      last_name: 'Else',
      candidate_status: @pending_status,
      user: users(:hr_user)  # linked to a different user
    )
    login_as 'regular'
    get candidate_path(other_users_candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'name-collision does not leak a FK-owned candidate to a non-owner' do
    # A candidate whose first.last name matches the self.candidate fixture's
    # user_name, but whose FK points at `regular`. The self.candidate user
    # must NOT be able to view it — the FK is the source of truth.
    candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @pending_status,
      user: users(:regular)
    )
    login_as 'self.candidate'
    get candidate_path(candidate)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'admin can set user_id when creating a candidate' do
    login_as 'admin'
    assert_difference -> { Candidate.count }, 1 do
      post candidates_path, params: {
        candidate: {
          first_name: 'Linked',
          last_name: 'Candidate',
          candidate_status_id: @pending_status.id,
          user_id: users(:regular).id
        }
      }
    end
    assert_equal users(:regular).id, Candidate.last.user_id
  end
end
