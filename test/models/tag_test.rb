require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "tag requires a name" do
    tag = Tag.new(name: nil)
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "tag name must be unique" do
    Tag.create!(name: "Unique")
    duplicate = Tag.new(name: "Unique")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "chip_color returns the color when set" do
    tag = Tag.new(name: "Red", color: "#ff0000")
    assert_equal "#ff0000", tag.chip_color
  end

  test "chip_color falls back to Pico primary when color is blank" do
    tag = Tag.new(name: "Default", color: nil)
    assert_equal "#1095c1", tag.chip_color
  end

  test "tagging a candidate creates a join record" do
    status = CandidateStatus.create!(code: "PEND", name: "Pending")
    candidate = Candidate.create!(first_name: "Alice", last_name: "A", candidate_status: status)
    tag = Tag.create!(name: "Frontend")

    candidate.tags << tag

    assert_includes candidate.reload.tags, tag
    assert_includes tag.reload.candidates, candidate
  end

  test "removing a tag from a candidate destroys the join record" do
    status = CandidateStatus.create!(code: "PEND", name: "Pending")
    candidate = Candidate.create!(first_name: "Bob", last_name: "B", candidate_status: status)
    tag = Tag.create!(name: "Backend")

    candidate.tags << tag
    assert_equal 1, CandidateTag.count

    candidate.tags.delete(tag)
    assert_equal 0, CandidateTag.count
  end

  test "destroying a candidate cascades to its candidate_tags" do
    status = CandidateStatus.create!(code: "PEND", name: "Pending")
    candidate = Candidate.create!(first_name: "Carol", last_name: "C", candidate_status: status)
    tag = Tag.create!(name: "Senior")
    candidate.tags << tag

    assert_difference -> { CandidateTag.count }, -1 do
      candidate.destroy!
    end
    assert Tag.exists?(tag.id), "the Tag itself should survive candidate deletion"
  end

  test "destroying a tag cascades to its candidate_tags" do
    status = CandidateStatus.create!(code: "PEND", name: "Pending")
    candidate = Candidate.create!(first_name: "Dave", last_name: "D", candidate_status: status)
    tag = Tag.create!(name: "Contract")
    candidate.tags << tag

    assert_difference -> { CandidateTag.count }, -1 do
      tag.destroy!
    end
    assert Candidate.exists?(candidate.id), "the Candidate should survive tag deletion"
  end

  test "assigning tags via tag_ids on candidate update" do
    status = CandidateStatus.create!(code: "PEND", name: "Pending")
    candidate = Candidate.create!(first_name: "Eve", last_name: "E", candidate_status: status)
    t1 = Tag.create!(name: "Junior")
    t2 = Tag.create!(name: "Remote")

    candidate.update!(tag_ids: [ t1.id, t2.id ])
    assert_equal 2, candidate.tags.count

    candidate.update!(tag_ids: [ t1.id ])
    assert_equal 1, candidate.reload.tags.count
    assert_includes candidate.tags, t1
    refute_includes candidate.tags, t2
  end
end
