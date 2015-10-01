class LoginController < ApplicationController
  skip_before_filter(:check_login)

  def index
  end

  def attempt_login
    reset_session

    username = params[:username]
    password = params[:password]
    user = AuthenticationHelper::Authenticator.new.authenticate(username, password)

    if user.nil?
      redirect_to(:action => :index)
      return
    end
    session[:username] = user.auth_name
    session[:admin] = user.admin?

    redirect_to :controller => :dashboard
  end

end
