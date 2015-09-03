class LoginController < ApplicationController
  require 'net/ldap'

  skip_before_filter(:check_login)

  def index
  end

  def attempt_login
    reset_session
    username = params[:username]
    password = params[:password]
    user = authenticate(username, password)
    if user.nil?
      redirect_to(:action => :index)
      return
    end
    session[:username] = username
    redirect_to :controller => :dashboard
  end

  def authenticate(username, password)
    auth_type = AuthConfig::config['auth_type'] || 'none'
    return username if (auth_type.eql?('none'))
    if auth_type.eql?('ActiveDirectory')
      ad_server = AuthConfig::config['ad_server']
      ad_port = AuthConfig::config['ad_port']
      ad_base = AuthConfig::config['ad_base']
      ad_domain = AuthConfig::config['ad_domain']
      ad_user = "#{username}@#{ad_domain}"

      conn = Net::LDAP.new :host => ad_server,
                           :port => ad_port,
                           :base => ad_base,
                           :auth => {:username => ad_user,
                                     :password => password,
                                     :method => :simple}
      user_filter = Net::LDAP::Filter.eq('sAMAccountName', username)
      op_filter = Net::LDAP::Filter.eq('objectClass', 'organizationalPerson')

      conn.bind
      user = conn.search(:filter => op_filter & user_filter)

      if user
        return username
      else
        return nil
      end
    end
  rescue Net::LDAP::LdapError => e
    return e.message
  end
end
