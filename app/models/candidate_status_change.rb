# Append-only record of a candidate moving from one status to another.
# Created by Candidate's after_create / after_update callbacks whenever
# candidate_status_id changes. See the migration for schema rationale.
class CandidateStatusChange < ApplicationRecord
  belongs_to :candidate,   optional: true
  belongs_to :from_status, class_name: "CandidateStatus", optional: true
  belongs_to :to_status,   class_name: "CandidateStatus", optional: true
  belongs_to :changed_by, class_name: "User", foreign_key: :changed_by_user_id, optional: true, inverse_of: false

  scope :recent,         -> { order(created_at: :desc) }
  scope :for_candidate,  ->(candidate) { where(candidate_id: candidate.id) }

  # Human-readable summary for views: "Pending → Hired" or "→ Pending"
  # (no from_status on initial creation).
  def summary
    from = from_status&.name || from_status&.code
    to   = to_status&.name   || to_status&.code   || "unknown"
    from ? "#{from} → #{to}" : "→ #{to}"
  end
end
