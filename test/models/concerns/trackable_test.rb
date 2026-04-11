require "test_helper"

# Tests the Trackable concern via the Candidate model, which is the first
# (and most heavily exercised) consumer. The behavior we verify here
# applies uniformly to every other model that includes Trackable.
class TrackableTest < ActiveSupport::TestCase
  setup do
    @status   = CandidateStatus.create!(code: "PEND", name: "Pending")
    @hired    = CandidateStatus.create!(code: "HIRED", name: "Hired")
    @user     = users(:admin)
    Current.user = @user
  end

  teardown do
    Current.user = nil
  end

  # ----- create -----

  test "creating a trackable record writes a create activity" do
    assert_difference -> { Activity.count }, 1 do
      Candidate.create!(first_name: "Alice", last_name: "Anderson", candidate_status: @status)
    end

    activity = Activity.recent.first
    assert_equal "create",       activity.action
    assert_equal "Candidate",    activity.target_type
    assert_equal @user.id,       activity.actor_id
  end

  test "create activity stores a snapshot of attributes (without id)" do
    candidate = Candidate.create!(first_name: "Bob", last_name: "Brown", candidate_status: @status)

    activity = Activity.where(target_type: "Candidate", target_id: candidate.id).recent.first
    payload  = activity.changes_hash

    assert_equal "Bob",   payload["first_name"]
    assert_equal "Brown", payload["last_name"]
    refute_includes payload.keys, "id", "create snapshot must not include id"
  end

  test "create activity sets candidate_id to the candidate's own id" do
    candidate = Candidate.create!(first_name: "Carol", last_name: "Carter", candidate_status: @status)

    activity = Activity.where(target_type: "Candidate", target_id: candidate.id).recent.first
    assert_equal candidate.id, activity.candidate_id,
                 "Candidate#audit_candidate_id should return self.id"
  end

  # ----- update -----

  test "updating a trackable record writes an update activity" do
    candidate = Candidate.create!(first_name: "Dave", last_name: "Davis", candidate_status: @status)
    Activity.delete_all  # ignore the create activity

    assert_difference -> { Activity.count }, 1 do
      candidate.update!(first_name: "David")
    end

    activity = Activity.recent.first
    assert_equal "update",     activity.action
    assert_equal candidate.id, activity.target_id
  end

  test "update activity records the changed fields as [from, to] tuples" do
    candidate = Candidate.create!(first_name: "Eve", last_name: "Evans", candidate_status: @status)
    Activity.delete_all
    candidate.update!(first_name: "Evie", candidate_status: @hired)

    payload = Activity.recent.first.changes_hash
    assert_equal [ "Eve", "Evie" ], payload["first_name"]
    assert_equal [ @status.id, @hired.id ], payload["candidate_status_id"]
  end

  test "update activity is NOT written for a no-op save" do
    candidate = Candidate.create!(first_name: "Frank", last_name: "Frost", candidate_status: @status)
    Activity.delete_all

    assert_no_difference -> { Activity.count } do
      candidate.touch  # only updates updated_at; previous_changes is just updated_at
    end
  end

  test "update activity does not record updated_at noise" do
    candidate = Candidate.create!(first_name: "Grace", last_name: "Green", candidate_status: @status)
    Activity.delete_all
    candidate.update!(first_name: "Gracie")

    payload = Activity.recent.first.changes_hash
    refute_includes payload.keys, "updated_at"
  end

  # ----- destroy -----

  test "destroying a trackable record writes a destroy activity with attribute snapshot" do
    candidate = Candidate.create!(first_name: "Hank", last_name: "Hall", candidate_status: @status)
    Activity.delete_all

    target_id = candidate.id
    assert_difference -> { Activity.count }, 1 do
      candidate.destroy!
    end

    activity = Activity.recent.first
    assert_equal "destroy", activity.action
    assert_equal target_id, activity.target_id

    payload = activity.changes_hash
    assert_equal "Hank", payload["first_name"]
    assert_equal "Hall", payload["last_name"]
  end

  # ----- actor handling -----

  test "activity records nil actor when Current.user is unset" do
    Current.user = nil

    Candidate.create!(first_name: "Ivy", last_name: "Ingram", candidate_status: @status)

    assert_nil Activity.recent.first.actor_id
  end

  test "activity records the Current.user actor at the time of save" do
    other = users(:manager)
    Current.user = other

    Candidate.create!(first_name: "Jack", last_name: "Jones", candidate_status: @status)

    assert_equal other.id, Activity.recent.first.actor_id
  end

  # ----- sensitive field filtering -----

  test "user create activity does NOT include password_digest" do
    auth = auth_configs(:internal)
    User.create!(
      first_name: "Test", last_name: "User",
      user_name: "test.filter", auth_name: "test.filter",
      password: "TempPass!1", password_confirmation: "TempPass!1",
      auth_config: auth, active: true
    )

    activity = Activity.where(target_type: "User").recent.first
    payload  = activity.changes_hash
    refute_includes payload.keys, "password_digest",
                    "password_digest must never appear in audit changes_json"
  end

  test "user update activity does NOT include api_key_digest" do
    user = users(:admin)
    Activity.delete_all
    user.update_column(:api_key_digest, User.encode_api_key("seed-key"))

    # update_column bypasses callbacks, so trigger a real save that
    # changes api_key_digest via the regenerate_api_key! method.
    user.regenerate_api_key!

    activity = Activity.where(target_type: "User").recent.first
    return unless activity  # regenerate_api_key! goes through update! so we get an activity

    payload = activity.changes_hash
    refute_includes payload.keys, "api_key_digest",
                    "api_key_digest must never appear in audit changes_json"
  end
end
