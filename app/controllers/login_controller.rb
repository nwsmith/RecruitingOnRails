class LoginController < ApplicationController
  require 'net/ldap'

  def login
    reset_session
    username = params[:username]
    password = params[:password]
    user = authenticate(username, password)
    redirect_to :controller => :dashboard unless user.nil?
  end

  def authenticate(username, password)
    auth_type = AuthConfig::config[:auth_type]
    return username if (auth_type.eql?('none'))
    if auth_type.eql?('ldap')
      # do ldap
      true
    end
  end
end
