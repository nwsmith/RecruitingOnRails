class ApplicationController < ActionController::Base
  before_filter :check_login
  protect_from_forgery

  def check_login
    #TODO: Look in AD again
    username = session[:username]
    if username.nil? || username.empty?
      redirect_to(:controller => "login", :action => "index")
    end
  end
end
