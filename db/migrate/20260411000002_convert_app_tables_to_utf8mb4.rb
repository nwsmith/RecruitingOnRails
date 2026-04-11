# Convert all application tables from the deprecated utf8mb3 charset to
# utf8mb4. utf8mb3 is MySQL's "almost UTF-8" — it can only represent
# Basic Multilingual Plane characters and silently truncates 4-byte
# characters (most emoji, some CJK ideographs, supplementary scripts).
# MySQL has deprecated it and recommends utf8mb4 for all new tables.
#
# The active_storage_* tables already use utf8mb4 (they were created
# more recently) and are intentionally not in the list below. The Rails
# internals (schema_migrations, ar_internal_metadata) are also left
# alone — Rails manages their charset via its own conventions.
#
# This migration is up-only. Reverting to utf8mb3 would silently truncate
# any 4-byte characters that have been written since the upgrade, which
# is exactly the data-loss case the upgrade exists to prevent.
class ConvertAppTablesToUtf8mb4 < ActiveRecord::Migration[8.1]
  TABLES = %w[
    associated_budgets
    auth_config_types
    auth_configs
    budgeting_types
    candidate_attachments
    candidate_sources
    candidate_statuses
    candidates
    code_problems
    code_submission_reviews
    code_submissions
    diary_entries
    diary_entry_types
    education_levels
    experience_levels
    genders
    groups
    groups_users
    interview_reviews
    interview_types
    interviews
    leave_reasons
    office_locations
    positions
    previous_employers
    reference_checks
    registries
    review_results
    schools
    users
    work_history_rows
  ].freeze

  def up
    TABLES.each do |table|
      execute <<~SQL
        ALTER TABLE `#{table}`
          CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          'Reverting to utf8mb3 would silently truncate any 4-byte characters ' \
          'written since the upgrade. Restore from a pre-migration backup instead.'
  end
end
