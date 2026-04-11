require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user is redirected to login" do
    get dashboard_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "expired session is redirected to login" do
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    # Simulate expired session by traveling forward in time
    travel 3.hours do
      get dashboard_path
      assert_redirected_to controller: 'login', action: 'index'
    end
  end

  test "authenticated user can access dashboard" do
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    get dashboard_path
    assert_response :success
  end

  test "session expiry is extended on each request" do
    post login_attempt_login_path, params: { username: 'admin', password: 'password' }
    travel 1.hour do
      get dashboard_path
      assert_response :success
    end
    # Still valid 1 hour after the extension
    travel 2.hours do
      get dashboard_path
      assert_response :success
    end
  end

  # ----- Bearer token API key auth -----
  #
  # The cleanup pass rewrote check_login to accept the API key only from the
  # Authorization header (Bearer/Token/bare), never from a `?api_key=` query
  # parameter, so the key cannot leak into URLs or access logs. The
  # presented plaintext is HMAC-SHA256'd before lookup; the database stores
  # only the digest in users.api_key_digest. The tests below seed the
  # digest directly via update_column so we know which plaintext to present.

  def stash_api_key(user, plaintext)
    user.update_column(:api_key_digest, User.encode_api_key(plaintext))
  end

  test "valid Bearer token authenticates without a session" do
    stash_api_key(users(:admin), 'valid-key-1')

    get dashboard_path, headers: { 'Authorization' => 'Bearer valid-key-1' }
    assert_response :success
  end

  test "Token prefix is also accepted" do
    stash_api_key(users(:admin), 'valid-key-2')

    get dashboard_path, headers: { 'Authorization' => 'Token valid-key-2' }
    assert_response :success
  end

  test "bare key without scheme is also accepted" do
    stash_api_key(users(:admin), 'valid-key-3')

    get dashboard_path, headers: { 'Authorization' => 'valid-key-3' }
    assert_response :success
  end

  test "unknown API key is rejected" do
    get dashboard_path, headers: { 'Authorization' => 'Bearer no-such-key' }
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "API key for an inactive user is rejected" do
    stash_api_key(users(:inactive), 'inactive-key')

    get dashboard_path, headers: { 'Authorization' => 'Bearer inactive-key' }
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "api_key in query params is NOT honored" do
    stash_api_key(users(:admin), 'query-param-key')

    # No Authorization header, no session — query param must be ignored.
    get dashboard_path, params: { api_key: 'query-param-key' }
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "blank Authorization header falls through to session auth" do
    # Empty header value should not crash and should not authenticate.
    get dashboard_path, headers: { 'Authorization' => '' }
    assert_redirected_to controller: 'login', action: 'index'
  end

  test "presented plaintext is HMAC'd before lookup, not stored verbatim" do
    stash_api_key(users(:admin), 'real-plaintext')

    digest = users(:admin).reload.api_key_digest
    refute_equal 'real-plaintext', digest, 'digest must not equal plaintext'
    assert_equal User.encode_api_key('real-plaintext'), digest
  end
end
