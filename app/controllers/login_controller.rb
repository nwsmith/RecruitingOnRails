class LoginController < ApplicationController
  skip_before_action(:check_login)

  def index
    reset_session
  end

  def attempt_login
    reset_session

    username = params[:username]
    password = params[:password]
    user = AuthenticationHelper::Authenticator.new.authenticate(username, password)

    if user.nil? || !user.active?
      redirect_to(:action => :index)
      return
    end

    session[:username] = user.auth_name
    session[:user_id] = user.id
    session[:expires_at] = Time.current + 2.hours

    redirect_to :controller => :dashboard
  end

end
