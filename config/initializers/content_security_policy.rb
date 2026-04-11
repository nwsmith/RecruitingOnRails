# Content Security Policy.
#
# This is a defense-in-depth header against XSS: even if an attacker manages
# to inject a <script> tag into a rendered view, the browser refuses to
# execute it unless it matches the policy below.
#
# All resources are loaded from same-origin (`'self'`), with two specific
# allowances:
#
#   img-src 'self' data:
#     The favicon in the layout is a `data:image/svg+xml,...` URL.
#
#   style-src 'self' 'unsafe-inline'
#     The color_span helper (app/helpers/application_helper.rb) and the
#     diary entry link in candidates/show.html.erb emit inline
#     `style="color: #..."` attributes based on per-record DB color
#     values. CSP nonces only protect <style> *elements*, not style=""
#     *attributes*, so nonces aren't an option for these. CSS injection
#     is a much narrower threat surface than script injection — no code
#     execution, mostly limited to UI redress and constrained
#     exfiltration via background-image URLs — and the W3C/OWASP both
#     treat allowing 'unsafe-inline' on style-src (while keeping it off
#     script-src) as an acceptable compromise.
#
# Importmap-rails emits two inline scripts on every page (the
# `<script type="importmap">` JSON manifest and the `<script type="module">`
# entry loader). Those would otherwise need 'unsafe-inline' on script-src
# to run. Instead we enable Rails' per-request nonce generator and add
# script-src to nonce_directives — Rails automatically appends
# 'nonce-XXX' to the script-src directive in each response, and the
# importmap-rails helpers automatically add the matching `nonce="XXX"`
# attribute to their inline tags. Net effect: script-src stays at 'self'
# plus nonces, with no 'unsafe-inline' allowance for scripts at all.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src     :self
    policy.script_src      :self
    policy.style_src       :self, :unsafe_inline
    policy.img_src         :self, :data
    policy.font_src        :self
    policy.connect_src     :self
    policy.object_src      :none
    policy.base_uri        :self
    policy.form_action     :self
    policy.frame_ancestors :none
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
