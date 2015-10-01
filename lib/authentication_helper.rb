require 'digest/sha2'
require 'net/ldap'

module AuthenticationHelper
  class InternalLogin
    def authenticate(user, password)
      hashed_password = Digest::SHA2.base64digest(password)
      user.password.eql?(hashed_password) ? user : nil
    end
  end

  class LDAPLogin
    def authenticate(user, password)
      auth_config = user.auth_config

      ad_user = "#{user.user_name}@#{auth_config.ldap_domain}"

      conn = Net::LDAP.new :host => auth_config.server,
                           :port => auth_config.port,
                           :base => auth_config.ldap_base,
                           :auth => {:username => ad_user,
                                     :password => password,
                                     :method => :simple}
      user_filter = Net::LDAP::Filter.eq('sAMAccountName', user.user_name)
      op_filter = Net::LDAP::Filter.eq('objectClass', 'organizationalPerson')
      conn.bind
      ldap_user = conn.search(:filter => op_filter & user_filter)

      return ldap_user.nil? ? nil : user
    rescue Net::LDAP::LdapError => e
      return e.message
    end
  end

  class LoginFactory
    def LoginFactory.build(auth_type)
      {:INTERNAL => AuthenticationHelper::InternalLogin, :AD => AuthenticationHelper::LDAPLogin}[auth_type].new
    end
  end

  class Authenticator
    def authenticate(username, password)
      user = User.fetch_by_auth_name(username)
      return nil if user.nil?

      auth_type = user.auth_config.auth_config_type.code.to_sym
      AuthenticationHelper::LoginFactory.build(auth_type).authenticate(user, password)
    end
  end

end