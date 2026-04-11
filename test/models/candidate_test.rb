require 'test_helper'

class CandidateTest < ActiveSupport::TestCase
  setup do
    @pending = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @verbal  = CandidateStatus.create!(code: 'VERBAL', name: 'Verbal Offer')
    @hired   = CandidateStatus.create!(code: 'HIRED', name: 'Hired')
  end

  # ----- for_self_user: FK-first matching -----

  test 'for_self_user returns none for nil user' do
    assert_equal [], Candidate.for_self_user(nil).to_a
  end

  test 'for_self_user returns the FK-matched candidate regardless of name' do
    # The canonical case this FK was introduced for: a real user whose
    # user_name does NOT follow the first.last convention, but whose
    # candidate record is explicitly linked via user_id. Before the FK,
    # the dashboard would have silently failed to find this candidate.
    user = users(:regular)  # user_name: "regular", nothing close to first.last
    candidate = Candidate.create!(
      first_name: 'Totally',
      last_name: 'Different',
      candidate_status: @pending,
      user: user
    )
    result = Candidate.for_self_user(user).to_a
    assert_equal [candidate], result
  end

  test 'for_self_user honors PEND and VERBAL but not HIRED' do
    user = users(:regular)
    pending_c = Candidate.create!(
      first_name: 'A', last_name: 'One',
      candidate_status: @pending, user: user
    )
    verbal_c = Candidate.create!(
      first_name: 'B', last_name: 'Two',
      candidate_status: @verbal, user: user
    )
    hired_c = Candidate.create!(
      first_name: 'C', last_name: 'Three',
      candidate_status: @hired, user: user
    )

    result = Candidate.for_self_user(user).to_a
    assert_includes result, pending_c
    assert_includes result, verbal_c
    refute_includes result, hired_c
  end

  test 'for_self_user falls back to first.last name match when FK is nil' do
    # self.candidate fixture: user_name "self.candidate", first "Self",
    # last "Candidate". This is the legacy path — a candidate created
    # before the FK existed.
    user = users(:self_candidate_user)
    candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @pending
      # no user_id set
    )
    result = Candidate.for_self_user(user).to_a
    assert_equal [candidate], result
  end

  test 'for_self_user does not leak a name-matching candidate owned via FK by someone else' do
    # Regression: if the self.candidate user's name happens to match a
    # candidate whose user_id points at a DIFFERENT user, the self.candidate
    # user must NOT see that candidate. The name fallback is scoped to
    # `where(user_id: nil)` specifically to prevent this.
    other_user = users(:regular)
    self_user  = users(:self_candidate_user)

    # A candidate named "Self Candidate" but owned via FK by `regular`.
    leaky_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @pending,
      user: other_user
    )

    result_for_self = Candidate.for_self_user(self_user).to_a
    refute_includes result_for_self, leaky_candidate,
                    'name fallback must not leak a FK-owned candidate'

    # And the FK owner does see it.
    result_for_other = Candidate.for_self_user(other_user).to_a
    assert_includes result_for_other, leaky_candidate
  end

  test 'for_self_user returns none for a user with a non first.last user_name and no FK match' do
    user = users(:regular)  # no candidate linked, no name match possible
    Candidate.create!(
      first_name: 'Someone',
      last_name: 'Else',
      candidate_status: @pending
    )
    assert_equal [], Candidate.for_self_user(user).to_a
  end

  test 'for_self_user prefers FK match even when a separate name match exists' do
    user = users(:self_candidate_user)

    # A name-only match (no FK) — the legacy path.
    name_match = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @pending
    )

    # An FK match with a completely different name — the modern path.
    fk_match = Candidate.create!(
      first_name: 'Renamed',
      last_name: 'Person',
      candidate_status: @pending,
      user: user
    )

    result = Candidate.for_self_user(user).to_a
    assert_includes result, fk_match,   'FK match must be returned'
    assert_includes result, name_match, 'name match must still be returned (legacy path)'
  end
end
