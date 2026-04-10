require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "authenticates with correct password" do
    user = users(:admin)
    assert user.authenticate('password')
  end

  test "rejects incorrect password" do
    user = users(:admin)
    assert_not user.authenticate('wrong')
  end

  test "password is hashed with bcrypt" do
    user = User.new(
      user_name: 'newuser',
      auth_name: 'newuser',
      first_name: 'New',
      last_name: 'User',
      auth_config: auth_configs(:internal),
      password: 'secret',
      password_confirmation: 'secret',
      active: true
    )
    assert user.save
    assert user.password_digest.start_with?('$2a$')
  end

  test "requires password confirmation on create" do
    user = User.new(
      user_name: 'newuser',
      auth_name: 'newuser',
      first_name: 'New',
      last_name: 'User',
      auth_config: auth_configs(:internal),
      password: 'secret',
      password_confirmation: 'wrong',
      active: true
    )
    assert_not user.save
  end

  test "name returns full name" do
    user = users(:admin)
    assert_equal 'Admin User', user.name
  end

  test "fetch_by_auth_name finds user" do
    user = User.fetch_by_auth_name('admin')
    assert_not_nil user
    assert_equal 'admin', user.auth_name
  end

  test "fetch_by_auth_name returns nil for unknown" do
    assert_nil User.fetch_by_auth_name('nonexistent')
  end

  test "all_active excludes inactive users" do
    active_users = User.all_active
    assert active_users.none? { |u| u.user_name == 'inactive' }
    assert active_users.any? { |u| u.user_name == 'admin' }
  end
end
