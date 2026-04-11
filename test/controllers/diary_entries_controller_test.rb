require "test_helper"

class DiaryEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = CandidateStatus.create!(code: "PEND", name: "Pending")
    @candidate = Candidate.create!(
      first_name: "Jane",
      last_name: "Doe",
      candidate_status: @status
    )
    @diary_entry = DiaryEntry.create!(
      candidate: @candidate,
      user: users(:admin),
      entry_date: Date.today,
      notes: "Initial note"
    )
  end


  # ----- auth -----

  test "unauthenticated request to index redirects to login" do
    get diary_entries_path
    assert_redirected_to controller: "login", action: "index"
  end

  test "unauthenticated request to show redirects to login" do
    get diary_entry_path(@diary_entry)
    assert_redirected_to controller: "login", action: "index"
  end

  test "unauthenticated create is rejected" do
    assert_no_difference -> { DiaryEntry.count } do
      post diary_entries_path, params: { diary_entry: { candidate_id: @candidate.id } }
    end
    assert_redirected_to controller: "login", action: "index"
  end

  # ----- manager gate: only admin + manager allowed -----

  test "admin can list diary entries" do
    login_as "admin"
    get diary_entries_path
    assert_response :success
  end

  test "manager can list diary entries" do
    login_as "manager"
    get diary_entries_path
    assert_response :success
  end

  test "hr cannot list diary entries (manager gate excludes hr)" do
    login_as "hruser"
    get diary_entries_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot list diary entries" do
    login_as "regular"
    get diary_entries_path
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "self candidate user cannot view their own pending candidates diary entry" do
    # Unlike interviews / code_submissions / candidate_attachments, diary
    # entries are manager+ only — the self-candidate branch must NOT open
    # them up even when the candidate is still PEND.
    self_candidate = Candidate.create!(
      first_name: "Self",
      last_name: "Candidate",
      candidate_status: @status
    )
    own_entry = DiaryEntry.create!(
      candidate: self_candidate,
      user: users(:admin),
      entry_date: Date.today,
      notes: "Private manager note about Self"
    )
    login_as "self.candidate"
    get diary_entry_path(own_entry)
    assert_redirected_to controller: "dashboard", action: "index"
  end

  # ----- happy paths for manager role -----

  test "manager can view a single diary entry" do
    login_as "manager"
    get diary_entry_path(@diary_entry)
    assert_response :success
  end

  test "new prefills candidate_id from query param" do
    login_as "admin"
    get new_diary_entry_path(candidate_id: @candidate.id)
    assert_response :success
    assert_match %r{<option selected="selected" value="#{@candidate.id}">}, response.body
  end

  test "create with valid params persists the diary entry" do
    login_as "admin"
    assert_difference -> { DiaryEntry.count }, 1 do
      post diary_entries_path, params: {
        diary_entry: {
          candidate_id: @candidate.id,
          user_id: users(:admin).id,
          entry_date: Date.today,
          notes: "Followup note"
        }
      }
    end
    assert_redirected_to diary_entry_path(DiaryEntry.last)
  end

  test "update changes notes" do
    login_as "admin"
    patch diary_entry_path(@diary_entry), params: { diary_entry: { notes: "Updated note" } }
    assert_redirected_to diary_entry_path(@diary_entry)
    assert_equal "Updated note", @diary_entry.reload.notes
  end

  test "destroy removes the diary entry" do
    login_as "admin"
    assert_difference -> { DiaryEntry.count }, -1 do
      delete diary_entry_path(@diary_entry)
    end
    assert_redirected_to diary_entries_path
  end

  # ----- regression: non-manager roles also blocked on write paths -----

  test "hr cannot create a diary entry" do
    login_as "hruser"
    assert_no_difference -> { DiaryEntry.count } do
      post diary_entries_path, params: {
        diary_entry: {
          candidate_id: @candidate.id,
          user_id: users(:hr_user).id,
          entry_date: Date.today,
          notes: "Should not persist"
        }
      }
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end

  test "regular user cannot destroy a diary entry" do
    login_as "regular"
    assert_no_difference -> { DiaryEntry.count } do
      delete diary_entry_path(@diary_entry)
    end
    assert_redirected_to controller: "dashboard", action: "index"
  end
end
