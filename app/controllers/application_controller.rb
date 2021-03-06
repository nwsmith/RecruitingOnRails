class ApplicationController < ActionController::Base
  before_action :check_login
  protect_from_forgery

  def check_login
    if !params[:api_key] && (session[:expires_at].nil? || session[:expires_at].to_time < Time.current)
      redirect_to(:controller => 'login', :action => 'index')
      return
    end

    user = get_user

    if user.nil?
      redirect_to(:controller => 'login', :action => 'index')
    else
      init_session(user)
    end
  end

  def init_session(user)
    session[:admin] = user.admin?
    session[:manager] = session[:admin] || user.manager?
    session[:hr] = session[:manager] ||user.hr?
    session[:username] = user.user_name
    session[:expires_at] = Time.current + 2.hours
  end

  def get_user
    username = session[:username]
    user = User.where(user_name: username).first
    if user.nil?
      api_key = params[:api_key]
      user = User.where(api_key: api_key).first
    end

    user
  end

  def check_admin
    if session[:admin].nil? || !session[:admin]
      redirect_to(:controller => 'dashboard', :action => 'index')
    end
  end

  def check_manager
    if session[:manager].nil? || !session[:manager]
      redirect_to(:controller => 'dashboard', :action => 'index')
    end
  end


  def get_list_from_params(params, name)
    if params[name].nil?
      Array.new
    else
      (params[name].is_a? String) ? params[name].split(',') : params[name]
    end
  end

end
