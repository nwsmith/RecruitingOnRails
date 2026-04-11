require "test_helper"

# Regression check for the Content-Security-Policy header configured in
# config/initializers/content_security_policy.rb. The goal is to catch
# accidental drift back toward 'unsafe-inline' for script-src or losing
# the nonce mechanism that lets importmap-rails inline scripts run under
# a strict policy.
class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "CSP header is present on every authenticated page" do
    login_as "admin"
    get dashboard_path

    assert_response :success
    csp = response.headers["Content-Security-Policy"]
    assert csp.present?, "Content-Security-Policy header is missing"
  end

  test "CSP keeps script-src strict (self + per-request nonce, no unsafe-inline)" do
    login_as "admin"
    get dashboard_path

    csp = response.headers["Content-Security-Policy"]
    script_src = csp[/script-src[^;]*/]

    assert script_src.present?, "script-src directive missing from CSP: #{csp}"
    assert_match %r{\bscript-src 'self'}, script_src
    assert_match %r{'nonce-[A-Za-z0-9+/=]+'}, script_src,
                 "script-src must include a per-request nonce: #{script_src}"
    refute_match %r{'unsafe-inline'}, script_src,
                 "script-src must NOT allow 'unsafe-inline': #{script_src}"
    refute_match %r{'unsafe-eval'}, script_src,
                 "script-src must NOT allow 'unsafe-eval': #{script_src}"
  end

  test "CSP locks down default-src, object-src, base-uri, form-action, frame-ancestors" do
    login_as "admin"
    get dashboard_path

    csp = response.headers["Content-Security-Policy"]

    assert_match %r{default-src 'self'}, csp
    assert_match %r{object-src 'none'}, csp
    assert_match %r{base-uri 'self'}, csp
    assert_match %r{form-action 'self'}, csp
    assert_match %r{frame-ancestors 'none'}, csp
  end

  test "CSP allows data: URLs in img-src for the favicon" do
    login_as "admin"
    get dashboard_path

    csp = response.headers["Content-Security-Policy"]
    img_src = csp[/img-src[^;]*/]

    assert img_src.present?, "img-src directive missing from CSP: #{csp}"
    assert_match %r{data:}, img_src,
                 "img-src must allow data: URLs (favicon is data:image/svg+xml): #{img_src}"
  end

  test "CSP keeps the inline importmap script tags nonced (so they actually run)" do
    login_as "admin"
    get dashboard_path

    csp = response.headers["Content-Security-Policy"]
    nonce = csp[/'nonce-([A-Za-z0-9+\/=]+)'/, 1]
    assert nonce.present?, "no nonce in CSP header: #{csp}"

    # Both inline tags emitted by javascript_importmap_tags must carry the
    # same nonce attribute, otherwise the browser will block them under
    # the strict script-src.
    importmap_tag = response.body[%r{<script[^>]*type="importmap"[^>]*>}]
    module_tag    = response.body[%r{<script[^>]*type="module"[^>]*>}]

    assert importmap_tag.present?, 'expected an inline <script type="importmap"> tag'
    assert module_tag.present?,    'expected an inline <script type="module"> tag'
    assert_includes importmap_tag, %(nonce="#{nonce}")
    assert_includes module_tag,    %(nonce="#{nonce}")
  end
end
