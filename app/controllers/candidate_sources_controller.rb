class CandidateSourcesController < ApplicationController
  before_action :check_staff

  def index
    @candidate_sources = CandidateSource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidate_sources }
    end
  end

  def show
    @candidate_source = CandidateSource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate_source }
    end
  end

  def new
    @candidate_source = CandidateSource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate_source }
    end
  end

  def edit
    @candidate_source = CandidateSource.find(params[:id])
  end

  def create
    @candidate_source = CandidateSource.new(candidate_source_params)

    respond_to do |format|
      if @candidate_source.save
        format.html { redirect_to @candidate_source, notice: "Candidate source was successfully created." }
        format.json { render json: @candidate_source, status: :created, location: @candidate_source }
      else
        format.html { render action: "new" }
        format.json { render json: @candidate_source.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @candidate_source = CandidateSource.find(params[:id])

    respond_to do |format|
      if @candidate_source.update(candidate_source_params)
        format.html { redirect_to @candidate_source, notice: "Candidate source was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @candidate_source.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @candidate_source = CandidateSource.find(params[:id])
    @candidate_source.destroy

    respond_to do |format|
      format.html { redirect_to candidate_sources_url }
      format.json { head :no_content }
    end
  end

  private

  def candidate_source_params
    params.require(:candidate_source).permit(:code, :name, :description)
  end
end
