class ReplacePasswordWithPasswordDigest < ActiveRecord::Migration[7.1]
  GUARD_ENV = "I_HAVE_PASSWORD_RESET_PLAN".freeze

  def up
    unless ENV[GUARD_ENV] == "yes"
      raise <<~ERR
        ============================================================
        REFUSING to rename users.password to users.password_digest.

        Old code stored SHA-256 base64 digests in users.password (via a
        custom `password=` setter calling Digest::SHA2.base64digest). New
        code uses has_secure_password, which expects bcrypt hashes in
        password_digest.

        This migration renames the column without re-hashing. After it
        runs, every internal-auth user (anyone whose auth flow checks
        the local users.password_digest column) will be unable to log
        in until their password is reset, because bcrypt will compare
        their supplied password against a SHA-256 digest and reject.

        LDAP users are unaffected — their credentials live on the LDAP
        server, not in this column.

        Before running this migration on production:

          1. Confirm whether any internal-auth users actually exist in
             the target environment. If everyone authenticates through
             LDAP, the lockout doesn't matter and you can proceed.
          2. If internal-auth users exist: have a password-reset plan
             ready (force-reset on next login, admin-driven reset,
             or out-of-band comms before deploy).
          3. Make sure at least one admin can still log in afterward
             (e.g., create an LDAP-auth admin first).

        When ready, re-run with:

          #{GUARD_ENV}=yes bin/rails db:migrate

        On a fresh dev DB the same env var bypasses the guard.
        ============================================================
      ERR
    end

    rename_column :users, :password, :password_digest
  end

  def down
    rename_column :users, :password_digest, :password
  end
end
