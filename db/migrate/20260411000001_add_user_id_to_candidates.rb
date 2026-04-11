class AddUserIdToCandidates < ActiveRecord::Migration[8.1]
  # Introduces an explicit Candidate -> User foreign key so
  # `Candidate.for_self_user` (and the self-candidate branch in
  # `check_candidate_access`) no longer depend on the fragile
  # `user.user_name == "first.last"` convention.
  #
  # Nullable on purpose: legacy rows, external hires without user accounts,
  # and candidates created before this migration all keep working via the
  # existing name-based fallback. No backfill required; no guard flag
  # needed — adding a nullable column is a safe, reversible migration.
  def change
    add_reference :candidates, :user, null: true, foreign_key: true
  end
end
