# Trackable: an opt-in concern that records every create / update / destroy
# on the including model as an Activity row, capturing:
#
#   - actor: Current.user (set in ApplicationController#check_login)
#   - candidate_id: the value returned by `audit_candidate_id` (default nil;
#     models override to point at the parent candidate when one exists)
#   - changes_json: a JSON-serialized hash of what changed, with sensitive
#     fields filtered out
#
# Usage:
#
#   class Candidate < ApplicationRecord
#     include Trackable
#
#     def audit_candidate_id
#       id   # the candidate IS the candidate
#     end
#   end
#
#   class Interview < ApplicationRecord
#     include Trackable
#
#     def audit_candidate_id
#       candidate_id   # this interview belongs to a candidate
#     end
#   end
#
# Models that aren't candidate-related (User, AuthConfig, reference data,
# etc.) just `include Trackable` and rely on the default `audit_candidate_id`
# returning nil.
#
# Sensitive fields filtered from changes_json by default:
#   - password_digest
#   - api_key_digest
# Models can extend the filter by overriding `audit_filtered_attributes`.
module Trackable
  extend ActiveSupport::Concern

  DEFAULT_FILTERED_ATTRIBUTES = %w[password_digest api_key_digest].freeze

  included do
    after_create  :record_activity_create
    after_update  :record_activity_update
    after_destroy :record_activity_destroy
  end

  # Override in including models that have a candidate parent. Default is nil
  # (no candidate association — e.g. for User, AuthConfig, reference data).
  def audit_candidate_id
    nil
  end

  # Override to add model-specific sensitive fields. Always include the
  # defaults via `super`.
  def audit_filtered_attributes
    DEFAULT_FILTERED_ATTRIBUTES
  end

  private

  def record_activity_create
    write_activity(action: "create", payload: filtered_attributes_snapshot)
  end

  def record_activity_update
    return if previous_changes.except("updated_at").empty?
    write_activity(action: "update", payload: filtered_previous_changes)
  end

  def record_activity_destroy
    write_activity(action: "destroy", payload: filtered_attributes_snapshot)
  end

  def write_activity(action:, payload:)
    Activity.create!(
      actor_id:     Current.user&.id,
      action:       action,
      target_type:  self.class.name,
      target_id:    id,
      candidate_id: audit_candidate_id,
      changes_json: payload.to_json
    )
  rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
    # An audit-write failure should never block the underlying business
    # operation. Log loudly and move on so the model save still succeeds.
    Rails.logger.error("Trackable: failed to write Activity for #{self.class.name}##{id}: #{e.message}")
  end

  def filtered_attributes_snapshot
    attributes.except("id", *audit_filtered_attributes)
  end

  def filtered_previous_changes
    previous_changes
      .except("updated_at", "created_at", *audit_filtered_attributes)
  end
end
