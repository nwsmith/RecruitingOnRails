# Helpers for safely running 20260410000003_replace_password_with_password_digest.
#
# Background: that migration renames `users.password` to `users.password_digest`
# without re-hashing. Old code stored SHA-256 base64 digests; new code uses
# `has_secure_password` which expects bcrypt. After the rename, every user with
# auth_config_type.code == 'INTERNAL' is locked out until their password is reset.
# LDAP-backed users (auth_config_type.code == 'AD') are unaffected because their
# credentials live on the LDAP server.
#
# Recommended deploy sequence (production):
#
#   # 1. Find out who is affected. Run BEFORE the migration.
#   bin/rails internal_auth:list_affected_users
#
#   # 2. If the count is 0 (everyone uses LDAP), no recovery needed:
#   I_HAVE_PASSWORD_RESET_PLAN=yes bin/rails db:migrate
#
#   # 3. If the count is > 0:
#   #    a) Make sure at least one LDAP-auth admin exists. If not, create one
#   #       in the LDAP directory and seed a row in `users` for them with
#   #       auth_config pointing at the AD AuthConfig.
#   #    b) Notify affected users out-of-band that their password will be
#   #       reset on deploy and they should expect a new temporary password.
#   #    c) Run the migration:
#   I_HAVE_PASSWORD_RESET_PLAN=yes bin/rails db:migrate
#   #    d) IMMEDIATELY invalidate the (now-meaningless) password_digest
#   #       values so the leftover SHA-256 strings can't be misinterpreted:
#   bin/rails internal_auth:invalidate_internal_passwords
#   #    e) For each affected user, set a temporary bcrypt password and hand
#   #       it to them through whatever side channel you use:
#   bin/rails internal_auth:set_temp_password[some.user,T3mpPass!]
#
# All three tasks below are read-only / idempotent / scoped narrowly so they
# can be re-run safely.

namespace :internal_auth do
  desc "List users whose login depends on the local password column (internal auth)"
  task list_affected_users: :environment do
    users = internal_auth_users
    if users.empty?
      puts "No internal-auth users. The bcrypt migration is safe to run with no recovery work."
      next
    end

    puts "#{users.length} internal-auth user(s) will need a password reset after the migration:"
    puts ""
    printf("  %-6s %-30s %-30s %s\n", "id", "user_name", "name", "active?")
    puts "  " + ("-" * 80)
    users.each do |u|
      printf("  %-6s %-30s %-30s %s\n", u.id, u.user_name, u.name, u.active? ? "yes" : "no")
    end
  end

  desc "Overwrite password_digest for every internal-auth user with an unmatchable sentinel"
  task invalidate_internal_passwords: :environment do
    abort_unless_post_migration!

    sentinel = BCrypt::Password.create(SecureRandom.hex(32)).to_s
    users = internal_auth_users
    if users.empty?
      puts "No internal-auth users to invalidate."
      next
    end

    updated = User.where(id: users.map(&:id)).update_all(password_digest: sentinel)
    puts "Invalidated password_digest for #{updated} internal-auth user(s)."
    puts "Use internal_auth:set_temp_password[user_name,new_password] to issue temporary passwords."
  end

  desc "Set a temporary bcrypt password for a single user. Usage: rake internal_auth:set_temp_password[user_name,new_password]"
  task :set_temp_password, [:user_name, :new_password] => :environment do |_t, args|
    abort_unless_post_migration!

    user_name = args[:user_name].to_s
    new_password = args[:new_password].to_s

    if user_name.empty? || new_password.empty?
      abort "Usage: rake internal_auth:set_temp_password[user_name,new_password]"
    end

    user = User.find_by(user_name: user_name)
    abort "No such user: #{user_name}" if user.nil?

    if user.auth_config&.auth_config_type&.code != "INTERNAL"
      abort "User #{user_name} is not internal-auth (auth_config_type=#{user.auth_config&.auth_config_type&.code.inspect}). " \
            "Their credentials live elsewhere; setting password_digest will have no effect."
    end

    user.password = new_password
    user.save!
    puts "Set temporary password for #{user_name}. Hand it to them out-of-band; they should change it on next login."
  end

  # ----- helpers -----

  # Returns User records whose auth flow checks the local password_digest.
  # Works both before AND after the column rename: if the column is named
  # "password" we still want the same set of users.
  def internal_auth_users
    User.joins(auth_config: :auth_config_type)
        .where(auth_config_types: { code: "INTERNAL" })
        .order(:id)
        .to_a
  end

  # The invalidate / set_temp_password tasks only make sense after the
  # column has been renamed to password_digest, because that's the column
  # has_secure_password writes to. Refuse to run beforehand.
  def abort_unless_post_migration!
    columns = ActiveRecord::Base.connection.columns(:users).map(&:name)
    return if columns.include?("password_digest")

    abort <<~ERR
      The users table does not have a password_digest column yet. Run the
      bcrypt migration first:

        I_HAVE_PASSWORD_RESET_PLAN=yes bin/rails db:migrate

      Then re-run this task.
    ERR
  end
end
