# First-class record of every candidate status transition. While the
# generic Activity audit trail (20260411000004) captures all attribute
# changes including status, CandidateStatusChange is purpose-built for
# the "who moved this candidate from X to Y and when" question that's
# the most common audit query in a recruiting workflow.
#
# No foreign key constraints: the status-change row must outlive any
# deletion of the candidate, the statuses, or the user who made the
# change. Indexes provide lookup speed without constraining destroys.
class CreateCandidateStatusChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_status_changes, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.bigint  :candidate_id,       null: false
      t.bigint  :from_status_id
      t.bigint  :to_status_id,       null: false
      t.bigint  :changed_by_user_id
      t.text    :notes
      t.datetime :created_at,        null: false
    end

    add_index :candidate_status_changes, :candidate_id
    add_index :candidate_status_changes, :created_at
  end
end
