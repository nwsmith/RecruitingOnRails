class LoginController < ApplicationController
  require 'net/ldap'

  skip_before_filter(:check_login)

  def index
  end

  def attempt_login
    reset_session
    logger.error("That's me, tryin'")
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
    #auth_type = AuthConfig::config['auth_type']
    auth_type = 'none'
    return username if (auth_type.eql?('none'))
    if auth_type.eql?('ldap')
      # do ldap
      true
    end
  end
end
