require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag = Tag.create!(name: "Frontend", color: "#e74c3c")
  end

  # ----- staff gate -----

  test "unauthenticated index redirects to login" do
    get tags_path
    assert_redirected_to root_path
  end

  test "regular user cannot list tags" do
    login_as "regular"
    get tags_path
    assert_redirected_to dashboard_path
  end

  # ----- staff happy paths -----

  test "admin can list tags" do
    login_as "admin"
    get tags_path
    assert_response :success
    assert_match "Frontend", response.body
  end

  test "admin can view a tag" do
    login_as "admin"
    get tag_path(@tag)
    assert_response :success
  end

  test "admin can render the new form" do
    login_as "admin"
    get new_tag_path
    assert_response :success
  end

  test "admin can create a tag with a color" do
    login_as "admin"
    assert_difference -> { Tag.count }, 1 do
      post tags_path, params: { tag: { name: "Backend", color: "#3498db" } }
    end
    created = Tag.last
    assert_redirected_to tag_path(created)
    assert_equal "Backend", created.name
    assert_equal "#3498db", created.color
  end

  test "admin can update a tag" do
    login_as "admin"
    patch tag_path(@tag), params: { tag: { name: "Front-End" } }
    assert_redirected_to tag_path(@tag)
    assert_equal "Front-End", @tag.reload.name
  end

  test "admin can destroy a tag" do
    login_as "admin"
    assert_difference -> { Tag.count }, -1 do
      delete tag_path(@tag)
    end
    assert_redirected_to tags_path
  end

  test "creating a tag with a duplicate name fails" do
    login_as "admin"
    assert_no_difference -> { Tag.count } do
      post tags_path, params: { tag: { name: "Frontend" } }
    end
    assert_response :unprocessable_entity
  end

  test "manager can list tags" do
    login_as "manager"
    get tags_path
    assert_response :success
  end

  test "hr can list tags" do
    login_as "hruser"
    get tags_path
    assert_response :success
  end
end
