# Activity log: append-only audit trail of every create/update/destroy
# on a tracked AR model. Captured by the Trackable concern.
#
#   - actor_id      → users.id of the human (or nil for system actions)
#   - action        → 'create', 'update', or 'destroy'
#   - target_type   → AR class name (polymorphic-style)
#   - target_id     → the affected record's id
#   - candidate_id  → denormalized for fast per-candidate timeline queries.
#                     Set by the model via `audit_candidate_id` (Candidate
#                     returns self.id; per-candidate associations like
#                     Interview return self.candidate_id; reference data
#                     returns nil).
#   - changes_json  → serialized previous_changes hash for create/update,
#                     or attribute snapshot for destroy. Sensitive fields
#                     (password_digest, api_key_digest) are filtered out
#                     by the Trackable concern.
#   - created_at    → when the activity happened. No updated_at — rows
#                     are append-only and never modified.
#
# Intentionally NO foreign key constraints on actor_id or candidate_id.
# Audit rows are append-only and must outlive the records they reference:
# if a user or candidate is ever deleted, their historical activities
# should remain visible (with a stale actor_id / candidate_id pointing
# at the now-gone row). FK constraints would either block the destroy
# or cascade-delete the audit history, both of which defeat the purpose
# of an audit log. Indexes give us the lookup speed we need without
# constraining destroys.
class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.bigint   :actor_id
      t.string   :action,      null: false
      t.string   :target_type, null: false
      t.bigint   :target_id,   null: false
      t.bigint   :candidate_id
      t.text     :changes_json
      t.datetime :created_at,  null: false
    end

    add_index :activities, :actor_id
    add_index :activities, :candidate_id
    add_index :activities, [ :target_type, :target_id ]
    add_index :activities, :created_at
  end
end
