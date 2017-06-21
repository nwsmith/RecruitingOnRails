class CandidateSourcesController < ApplicationController
  # GET /candidate_sources
  # GET /candidate_sources.json
  def index
    @candidate_sources = CandidateSource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidate_sources }
    end
  end

  # GET /candidate_sources/1
  # GET /candidate_sources/1.json
  def show
    @candidate_source = CandidateSource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate_source }
    end
  end

  # GET /candidate_sources/new
  # GET /candidate_sources/new.json
  def new
    @candidate_source = CandidateSource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate_source }
    end
  end

  # GET /candidate_sources/1/edit
  def edit
    @candidate_source = CandidateSource.find(params[:id])
  end

  # POST /candidate_sources
  # POST /candidate_sources.json
  def create
    @candidate_source = CandidateSource.new(user_params)

    respond_to do |format|
      if @candidate_source.save
        format.html { redirect_to @candidate_source, notice: 'Candidate source was successfully created.' }
        format.json { render json: @candidate_source, status: :created, location: @candidate_source }
      else
        format.html { render action: "new" }
        format.json { render json: @candidate_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /candidate_sources/1
  # PUT /candidate_sources/1.json
  def update
    @candidate_source = CandidateSource.find(params[:id])

    respond_to do |format|
      if @candidate_source.update_attributes(user_params)
        format.html { redirect_to @candidate_source, notice: 'Candidate source was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @candidate_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /candidate_sources/1
  # DELETE /candidate_sources/1.json
  def destroy
    @candidate_source = CandidateSource.find(params[:id])
    @candidate_source.destroy

    respond_to do |format|
      format.html { redirect_to candidate_sources_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:candidate_source).permit!
  end
end
