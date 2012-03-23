class CandidateStatusesController < ApplicationController
  # GET /candidate_statuses
  # GET /candidate_statuses.json
  def index
    @candidate_statuses = CandidateStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidate_statuses }
    end
  end

  # GET /candidate_statuses/1
  # GET /candidate_statuses/1.json
  def show
    @candidate_status = CandidateStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate_status }
    end
  end

  # GET /candidate_statuses/new
  # GET /candidate_statuses/new.json
  def new
    @candidate_status = CandidateStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate_status }
    end
  end

  # GET /candidate_statuses/1/edit
  def edit
    @candidate_status = CandidateStatus.find(params[:id])
  end

  # POST /candidate_statuses
  # POST /candidate_statuses.json
  def create
    @candidate_status = CandidateStatus.new(params[:candidate_status])

    respond_to do |format|
      if @candidate_status.save
        format.html { redirect_to @candidate_status, notice: 'Candidate status was successfully created.' }
        format.json { render json: @candidate_status, status: :created, location: @candidate_status }
      else
        format.html { render action: "new" }
        format.json { render json: @candidate_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /candidate_statuses/1
  # PUT /candidate_statuses/1.json
  def update
    @candidate_status = CandidateStatus.find(params[:id])

    respond_to do |format|
      if @candidate_status.update_attributes(params[:candidate_status])
        format.html { redirect_to @candidate_status, notice: 'Candidate status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @candidate_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /candidate_statuses/1
  # DELETE /candidate_statuses/1.json
  def destroy
    @candidate_status = CandidateStatus.find(params[:id])
    @candidate_status.destroy

    respond_to do |format|
      format.html { redirect_to candidate_statuses_url }
      format.json { head :no_content }
    end
  end
end
