# ActiveSupport::CurrentAttributes lets the model layer read the current
# request's user without threading it through every method call. The
# ApplicationController#check_login filter sets `Current.user` after
# determining the authenticated user; the Trackable concern reads
# `Current.user` from its callbacks to record the actor of each Activity.
#
# CurrentAttributes are reset between requests automatically (via
# ActionDispatch::Executor), so there's no leakage across requests.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
