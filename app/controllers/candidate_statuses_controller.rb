class CandidateStatusesController < ApplicationController
  before_action :check_staff

  def index
    @candidate_statuses = CandidateStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidate_statuses }
    end
  end

  def show
    @candidate_status = CandidateStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate_status }
    end
  end

  def new
    @candidate_status = CandidateStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate_status }
    end
  end

  def edit
    @candidate_status = CandidateStatus.find(params[:id])
  end

  def create
    @candidate_status = CandidateStatus.new(candidate_status_params)

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

  def update
    @candidate_status = CandidateStatus.find(params[:id])

    respond_to do |format|
      if @candidate_status.update(candidate_status_params)
        format.html { redirect_to @candidate_status, notice: 'Candidate status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @candidate_status.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @candidate_status = CandidateStatus.find(params[:id])
    @candidate_status.destroy

    respond_to do |format|
      format.html { redirect_to candidate_statuses_url }
      format.json { head :no_content }
    end
  end

  private

  def candidate_status_params
    params.require(:candidate_status).permit(:code, :name, :description)
  end
end
