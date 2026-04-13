require "test_helper"

class CandidateStatusChangeTest < ActiveSupport::TestCase
  setup do
    @pending = CandidateStatus.create!(code: "PEND", name: "Pending")
    @verbal  = CandidateStatus.create!(code: "VERBAL", name: "Verbal Offer")
    @hired   = CandidateStatus.create!(code: "HIRED", name: "Hired")
    Current.user = users(:admin)
  end

  teardown do
    Current.user = nil
  end

  # ----- initial status on create -----

  test "creating a candidate with a status records an initial status change" do
    assert_difference -> { CandidateStatusChange.count }, 1 do
      Candidate.create!(first_name: "Alice", last_name: "Anderson", candidate_status: @pending)
    end

    sc = CandidateStatusChange.recent.first
    assert_nil sc.from_status_id, "initial change has no from_status"
    assert_equal @pending.id, sc.to_status_id
    assert_equal users(:admin).id, sc.changed_by_user_id
  end

  test "initial status change summary reads as arrow-to" do
    candidate = Candidate.create!(first_name: "Bob", last_name: "Brown", candidate_status: @pending)
    sc = CandidateStatusChange.for_candidate(candidate).recent.first
    assert_equal "→ Pending", sc.summary
  end

  # ----- status update -----

  test "updating candidate_status_id records a status change with from and to" do
    candidate = Candidate.create!(first_name: "Carol", last_name: "Carter", candidate_status: @pending)
    CandidateStatusChange.delete_all

    assert_difference -> { CandidateStatusChange.count }, 1 do
      candidate.update!(candidate_status: @verbal)
    end

    sc = CandidateStatusChange.recent.first
    assert_equal @pending.id, sc.from_status_id
    assert_equal @verbal.id,  sc.to_status_id
    assert_equal candidate.id, sc.candidate_id
  end

  test "status change summary reads as from-arrow-to" do
    candidate = Candidate.create!(first_name: "Dave", last_name: "Davis", candidate_status: @pending)
    candidate.update!(candidate_status: @hired)

    sc = CandidateStatusChange.for_candidate(candidate).recent.first
    assert_equal "Pending → Hired", sc.summary
  end

  test "changing status twice produces a correct chain" do
    candidate = Candidate.create!(first_name: "Eve", last_name: "Evans", candidate_status: @pending)
    candidate.update!(candidate_status: @verbal)
    candidate.update!(candidate_status: @hired)

    changes = CandidateStatusChange.for_candidate(candidate).order(:created_at).to_a
    assert_equal 3, changes.size, "1 initial + 2 updates"

    assert_nil   changes[0].from_status_id
    assert_equal @pending.id, changes[0].to_status_id

    assert_equal @pending.id, changes[1].from_status_id
    assert_equal @verbal.id,  changes[1].to_status_id

    assert_equal @verbal.id,  changes[2].from_status_id
    assert_equal @hired.id,   changes[2].to_status_id
  end

  # ----- no-op updates -----

  test "updating a non-status field does NOT create a status change" do
    candidate = Candidate.create!(first_name: "Frank", last_name: "Frost", candidate_status: @pending)
    CandidateStatusChange.delete_all

    assert_no_difference -> { CandidateStatusChange.count } do
      candidate.update!(first_name: "Franklin")
    end
  end

  test "saving a candidate without changing the status does NOT create a status change" do
    candidate = Candidate.create!(first_name: "Grace", last_name: "Green", candidate_status: @pending)
    CandidateStatusChange.delete_all

    assert_no_difference -> { CandidateStatusChange.count } do
      candidate.touch
    end
  end

  # ----- actor tracking -----

  test "status change captures Current.user as changed_by" do
    other_user = users(:manager)
    Current.user = other_user

    candidate = Candidate.create!(first_name: "Hank", last_name: "Hall", candidate_status: @pending)
    sc = CandidateStatusChange.recent.first
    assert_equal other_user.id, sc.changed_by_user_id
  end

  test "status change records nil changed_by when Current.user is unset" do
    Current.user = nil

    candidate = Candidate.create!(first_name: "Ivy", last_name: "Ingram", candidate_status: @pending)
    sc = CandidateStatusChange.recent.first
    assert_nil sc.changed_by_user_id
  end
end
