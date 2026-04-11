# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
#
# :marshal is unsafe — if the secret_key_base ever leaks, an attacker can
# craft a cookie that triggers Ruby Marshal.load on the server side, which
# instantiates arbitrary Ruby classes (Remote Code Execution). :json is
# safe and is the Rails 7+ default for new apps.
#
# This app has no existing :marshal-format cookies in production (no prod
# exists), so we can switch to :json directly without a :hybrid migration
# window.
Rails.application.config.action_dispatch.cookies_serializer = :json
