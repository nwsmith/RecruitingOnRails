# Replace the plaintext `users.api_key` column with `users.api_key_digest`,
# an HMAC-SHA256 hex digest computed using Rails.application.secret_key_base
# as the HMAC key. The plaintext is shown to the human exactly once at
# generation time and never persisted, so a database leak (backup, logs,
# DBA-level access) cannot be turned into impersonation tokens — an attacker
# would need both the digest table AND the HMAC secret.
#
# No data migration: there are no production-issued plaintext keys to
# preserve. The fixture users don't carry api_key values either. Anyone
# who needs an API key after this migration can generate one via
# `user.regenerate_api_key!`.
class HashUserApiKeys < ActiveRecord::Migration[8.1]
  def up
    add_column    :users, :api_key_digest, :string
    add_index     :users, :api_key_digest, unique: true
    remove_column :users, :api_key
  end

  def down
    add_column    :users, :api_key, :string
    remove_index  :users, :api_key_digest
    remove_column :users, :api_key_digest
  end
end
