class ApplicationController < ActionController::Base
  before_filter :check_login
  protect_from_forgery

  def check_login
    username = session[:username]
    return unless username.nil? || username.empty?

    api_key = params[:api_key] || ''
    user = User.find_all_by_api_key(api_key)[0]

    if user.nil?
      redirect_to(:controller => 'login', :action => 'index') if user.nil?
    else
      session[:username] = user.user_name
      session[:admin] = user.admin?
    end
  end

  def check_admin
    if session[:admin].nil? || !session[:admin]
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
