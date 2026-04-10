class CandidatesController < ApplicationController

  # Returns true if access is denied and a redirect has been issued.
  # Callers MUST `return if check_access(...)` to avoid double-render.
  def check_access(candidate)
    return false if current_user&.hr? || current_user&.manager? || current_user&.admin?

    candidate_status_code = candidate.candidate_status&.code
    is_self = current_user&.user_name.to_s == candidate.username
    self_allowed = is_self && (candidate_status_code == 'PEND' || candidate_status_code == 'VERBAL')

    return false if self_allowed

    redirect_to(controller: 'dashboard', action: :index)
    true
  end

  # GET /candidates
  # GET /candidates.json
  def index
    @candidates = Candidate.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidates }
    end
  end

  def calendar
    p = params[:start_date] || Date.new.to_s
    d = Date.parse(p)

    @candidates = Candidate.all
    @candidates = @candidates.select{|c| !c.start_date.nil? && c.candidate_status&.code != 'QUIT' && c.candidate_status&.code != 'FIRED'}
    @candidates.each {|c| c.start_time = Date.new(d.year, c.start_date.month, c.start_date.day)}
  end

  def timeline
    @status_list = params[:status].nil? ? Array.new : (params[:status].split ',')
    @status_list << 'HIRED' if @status_list.empty?

    @group_by = params[:group_by].nil? ? 'YEAR' : params[:group_by]

    @candidates = Array.new
    @status_list.each {|s| @candidates << Candidate.by_status_code(s)}
    @candidates = @candidates.flatten

    respond_to do |format|
      format.html
    end
  end

  def events
    status_list = params[:status].nil? ? Array.new : (params[:status].split ',')
    status_list << 'HIRED' if status_list.empty?

    candidates = Array.new

    folks = Array.new
    status_list.each { |s| folks << Candidate.by_status_code(s) }
    folks = folks.flatten
    folks = folks.sort { |a, b| b.start_date <=> a.start_date || b.end_date <=> a.end_date }

    folks.each do |candidate|
      next if candidate.start_date.nil? || candidate.start_date > Date.today
      json = Hash.new
      json['start'] = candidate.start_date.to_s
      json['end'] = candidate.end_date.nil? ? Date.today.to_s : candidate.end_date.to_s
      #json['isDuration'] = true
      json['title'] = candidate.name
      candidates << json
    end

    events = Hash.new
    events['events'] = candidates

    respond_to do |format|
      format.html
      format.json { render json: events }
    end

  end

  def search
    query = params[:q].to_s.strip
    parts = query.split(/\s+/)

    @candidates =
      if parts.empty?
        Candidate.none
      elsif parts.length == 1
        term = "%#{escape_like(parts[0])}%"
        Candidate.where('first_name LIKE ? OR last_name LIKE ?', term, term)
      else
        # Treat the first token as first name and the rest as last name, but
        # also accept the reverse so "Doe John" and "John Marie Doe" both work.
        first_term = "#{escape_like(parts.first)}%"
        last_term  = "#{escape_like(parts.last)}%"
        Candidate.where(
          '(first_name LIKE ? AND last_name LIKE ?) OR (first_name LIKE ? AND last_name LIKE ?)',
          first_term, last_term, last_term, first_term
        )
      end

    render 'list'
  end

  def list
    status_list = params[:status].nil? ? Array.new : (params[:status].split ',')
    @candidates = Array.new

    status_list.each { |s| @candidates << Candidate.by_status_code(s) }
    @candidates = @candidates.flatten

    respond_to do |format|
      format.html
      format.json { render json: @candidates, :include => {:candidate_status => {:only => :code}, :candidate_source => {:only => :code}} }
    end
  end

  # GET /candidates/1
  # GET /candidates/1.json
  def show
    @candidate = Candidate.find(params[:id])

    return if check_access(@candidate)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate }
    end
  end

  # GET /candidates/new
  # GET /candidates/new.json
  def new
    @candidate = Candidate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate }
    end
  end

  # GET /candidates/1/edit
  def edit
    @candidate = Candidate.find(params[:id])
    return if check_access(@candidate)
  end

  # POST /candidates
  # POST /candidates.json
  def create
    @candidate = Candidate.new(user_params)

    respond_to do |format|
      if @candidate.save
        format.html { redirect_to @candidate, notice: 'Candidate was successfully created.' }
        format.json { render json: @candidate, status: :created, location: @candidate }
      else
        format.html { render action: 'new' }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /candidates/1
  # PUT /candidates/1.json
  def update
    @candidate = Candidate.find(params[:id])

    return if check_access(@candidate)

    respond_to do |format|
      if @candidate.update(user_params)
        format.html { redirect_to @candidate, notice: 'Candidate was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /candidates/1
  # DELETE /candidates/1.json
  def destroy
    @candidate = Candidate.find(params[:id])

    return if check_access(@candidate)

    @candidate.destroy

    respond_to do |format|
      format.html { redirect_to candidates_url }
      format.json { head :no_content }
    end
  end

  private

  # Escape LIKE wildcards so user input can't widen the match.
  def escape_like(str)
    str.to_s.gsub(/[\\%_]/) { |c| "\\#{c}" }
  end

  def user_params
    params.require(:candidate).permit(
      :first_name, :middle_name, :last_name, :notes,
      :application_date, :first_contact_date, :start_date, :end_date,
      :offer_date, :offer_accept_date, :offer_turndown_date,
      :rejection_notification_date, :rejection_call_request_date,
      :fire_date, :quit_date, :is_referral, :referred_by,
      :salary_range, :replacement_for, :sadness_factor,
      :candidate_status_id, :candidate_source_id, :experience_level_id,
      :position_id, :office_location_id, :education_level_id, :school_id,
      :gender_id, :leave_reason_id, :associated_budget_id, :budgeting_type_id
    )
  end
end
