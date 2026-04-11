class ApplicationController < ActionController::Base
  before_action :check_login
  protect_from_forgery

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def check_login
    # API key auth path: only accept the key from the Authorization header
    # (e.g. `Authorization: Bearer <key>`) so it never appears in URLs or logs.
    api_key = bearer_token_from_header
    if api_key.present?
      user = User.find_by(api_key: api_key)
      if user&.active?
        @current_user = user
        return
      else
        redirect_to(:controller => 'login', :action => 'index')
        return
      end
    end

    # Session auth path
    expires_at = begin
                   session[:expires_at]&.to_time
                 rescue ArgumentError, TypeError
                   nil
                 end
    if expires_at.nil? || expires_at < Time.current
      redirect_to(:controller => 'login', :action => 'index')
      return
    end

    if current_user.nil?
      redirect_to(:controller => 'login', :action => 'index')
    else
      session[:expires_at] = Time.current + 2.hours
    end
  end

  def check_admin
    unless current_user&.admin?
      redirect_to(:controller => 'dashboard', :action => 'index')
    end
  end

  def check_manager
    unless current_user&.admin? || current_user&.manager?
      redirect_to(:controller => 'dashboard', :action => 'index')
    end
  end

  # Staff gate: anyone in admin / manager / hr. Used for index actions on
  # candidate-related resources (interviews, code submissions, attachments)
  # where there's no per-record candidate to scope by.
  #
  # Returns true if access is denied and a redirect has been issued.
  # Callers MUST `return if check_staff` to avoid double-render.
  def check_staff
    return false if current_user&.staff?

    redirect_to(controller: 'dashboard', action: :index)
    true
  end

  # Per-candidate gate: admin/manager/hr always pass; otherwise the user can
  # only view records belonging to their OWN candidate while that candidate
  # is still in PEND or VERBAL status. Used by candidates_controller and the
  # related-resource controllers (interviews, code_submissions, attachments)
  # so a regular user can't enumerate someone else's hiring data.
  #
  # Returns true if access is denied and a redirect has been issued.
  # Callers MUST `return if check_candidate_access(candidate)` to avoid
  # double-render.
  def check_candidate_access(candidate)
    return false if current_user&.staff?

    if candidate.nil?
      redirect_to(controller: 'dashboard', action: :index)
      return true
    end

    candidate_status_code = candidate.candidate_status&.code
    is_self = current_user&.user_name.to_s == candidate.username
    self_allowed = is_self && (candidate_status_code == 'PEND' || candidate_status_code == 'VERBAL')

    return false if self_allowed

    redirect_to(controller: 'dashboard', action: :index)
    true
  end


  def bearer_token_from_header
    header = request.headers['Authorization'].to_s
    return nil if header.blank?
    # Accept "Bearer <key>", "Token <key>", or a bare key.
    header.sub(/\A(Bearer|Token)\s+/i, '').strip.presence
  end

  def get_list_from_params(params, name)
    if params[name].nil?
      Array.new
    else
      (params[name].is_a? String) ? params[name].split(',') : params[name]
    end
  end

end
