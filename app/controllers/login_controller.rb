class LoginController < ApplicationController
  skip_before_filter(:check_login)

  def index
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

    session[:admin] = user.admin?
    session[:manager] = session[:admin] || user.manager?
    session[:hr] = session[:manager] ||user.hr?

    redirect_to :controller => :dashboard
  end

end
