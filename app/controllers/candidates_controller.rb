class CandidatesController < ApplicationController

  def check_access(candidate)
    username = session[:username]
    candidate_username = candidate.username
    candidate_status = candidate.candidate_status

    return if session[:hr]

    if username.eql?(candidate_username) || !(candidate_status.code.eql?('PEND') || candidate_status.code.eql?('VERBAL'))
      redirect_to(:controller => 'dashboard', :action => :index)
    end
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
    @candidates = @candidates.select{|c| !c.start_date.nil? && c.candidate_status.code != 'QUIT' && c.candidate_status.code != 'FIRED'}
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
    folks.sort { |a, b| b.start_date <=> a.start_date || b.end_date <=> a.end_date }

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
    query = params[:q]
    name = query.split(' ')
    if name.length == 2
      conditions = ['first_name = ? AND last_name = ?', name[0], name[1]]
    else
      conditions = ['first_name LIKE ? OR last_name LIKE ?', "%#{name[0]}%", "%#{name[0]}%"]
    end

    @candidates = Candidate.where(conditions).all
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

    check_access(@candidate)

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
    check_access(@candidate)
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

    respond_to do |format|
      if @candidate.update_attributes(user_params)
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
    @candidate.destroy

    respond_to do |format|
      format.html { redirect_to candidates_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:candidate).permit!
  end
end
