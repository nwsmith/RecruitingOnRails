class InterviewTypesController < ApplicationController
  # GET /interview_types
  # GET /interview_types.json
  def index
    @interview_types = InterviewType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interview_types }
    end
  end

  # GET /interview_types/1
  # GET /interview_types/1.json
  def show
    @interview_type = InterviewType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interview_type }
    end
  end

  # GET /interview_types/new
  # GET /interview_types/new.json
  def new
    @interview_type = InterviewType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview_type }
    end
  end

  # GET /interview_types/1/edit
  def edit
    @interview_type = InterviewType.find(params[:id])
  end

  # POST /interview_types
  # POST /interview_types.json
  def create
    @interview_type = InterviewType.new(params[:interview_type])

    respond_to do |format|
      if @interview_type.save
        format.html { redirect_to @interview_type, notice: 'Interview type was successfully created.' }
        format.json { render json: @interview_type, status: :created, location: @interview_type }
      else
        format.html { render action: "new" }
        format.json { render json: @interview_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /interview_types/1
  # PUT /interview_types/1.json
  def update
    @interview_type = InterviewType.find(params[:id])

    respond_to do |format|
      if @interview_type.update_attributes(params[:interview_type])
        format.html { redirect_to @interview_type, notice: 'Interview type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interview_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interview_types/1
  # DELETE /interview_types/1.json
  def destroy
    @interview_type = InterviewType.find(params[:id])
    @interview_type.destroy

    respond_to do |format|
      format.html { redirect_to interview_types_url }
      format.json { head :no_content }
    end
  end
end
