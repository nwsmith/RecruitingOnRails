require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Current.user = users(:admin)
    @status = CandidateStatus.create!(code: "PEND", name: "Pending")
    @candidate = Candidate.create!(first_name: "Audit", last_name: "Target", candidate_status: @status)
    Current.user = nil
  end

  # ----- admin gate -----

  test "unauthenticated index redirects to login" do
    get activities_path
    assert_redirected_to root_path
  end

  test "manager cannot view activities" do
    login_as "manager"
    get activities_path
    assert_redirected_to dashboard_path
  end

  test "regular user cannot view activities" do
    login_as "regular"
    get activities_path
    assert_redirected_to dashboard_path
  end

  test "admin can view activities" do
    login_as "admin"
    get activities_path
    assert_response :success
  end

  # ----- filtering -----

  test "filtering by target_type narrows results" do
    login_as "admin"
    get activities_path(target_type: "Candidate")
    assert_response :success
    assert_match "Candidate##{@candidate.id}", response.body
  end

  test "filtering by candidate_id narrows results" do
    login_as "admin"
    get activities_path(candidate_id: @candidate.id)
    assert_response :success
    assert_match "Candidate##{@candidate.id}", response.body
  end

  test "filtering by actor_id narrows results" do
    # Set up an activity created by a known actor (admin from setup).
    Current.user = users(:admin)
    Candidate.create!(first_name: "Filtered", last_name: "By Actor", candidate_status: @status)
    Current.user = nil

    login_as "admin"
    get activities_path(actor_id: users(:admin).id)
    assert_response :success
    assert_match "Filtered", response.body
  end

  test "an unknown filter returns an empty result without erroring" do
    login_as "admin"
    get activities_path(target_type: "NoSuchClass")
    assert_response :success
    assert_match "No activities match", response.body
  end
end
