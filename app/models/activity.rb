require "json"

# Append-only audit log entry. Created by the Trackable concern via
# after_create / after_update / after_destroy callbacks. See the
# CreateActivities migration for the schema rationale.
#
# Activity is intentionally NOT itself Trackable: tracking the
# audit log would create an infinite recursion of activity rows
# describing the creation of activity rows.
class Activity < ApplicationRecord
  ACTIONS = %w[create update destroy].freeze

  belongs_to :actor,     class_name: "User",      optional: true
  belongs_to :candidate, optional: true

  validates :action,      inclusion: { in: ACTIONS }
  validates :target_type, presence: true
  validates :target_id,   presence: true

  scope :recent, -> { order(created_at: :desc) }

  # Decode the serialized changes hash. Returns {} for legacy rows
  # without a changes_json payload.
  def changes_hash
    return {} if changes_json.blank?
    JSON.parse(changes_json)
  rescue JSON::ParserError
    {}
  end

  # Resolve the polymorphic target if it still exists. Returns nil if
  # the row has been deleted (which is fine — the audit row outlives
  # the thing it's auditing, by design).
  def target
    return nil if target_type.blank? || target_id.blank?
    target_type.safe_constantize&.find_by(id: target_id)
  end

  # Human-readable verb for view templates.
  def action_verb
    case action
    when "create"  then "created"
    when "update"  then "updated"
    when "destroy" then "deleted"
    else action
    end
  end
end
