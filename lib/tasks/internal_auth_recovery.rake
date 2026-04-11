# Dev-only helper: set a bcrypt password on an existing internal-auth user.
#
# Useful when bootstrapping a local dev DB (e.g. you've seeded a user row via
# fixtures or the admin UI and need to assign it a known password to log in
# with). This task used to have two siblings — `list_affected_users` and
# `invalidate_internal_passwords` — that existed to safely run the
# `20260410000003_replace_password_with_password_digest` migration against a
# live production database. Since there's no production deployment, those
# tasks were dead scaffolding and have been removed.
#
# Usage:
#   bin/rails internal_auth:set_temp_password[some.user,T3mpPass!]
#
# The argument parsing is positional, so shell-quote the brackets in zsh:
#   bin/rails 'internal_auth:set_temp_password[some.user,T3mpPass!]'

namespace :internal_auth do
  desc "Set a bcrypt password for an existing internal-auth user. Usage: rake internal_auth:set_temp_password[user_name,new_password]"
  task :set_temp_password, [ :user_name, :new_password ] => :environment do |_t, args|
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
    puts "Set password for #{user_name}."
  end
end
