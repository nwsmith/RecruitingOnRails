class InterviewTypesController < ApplicationController
  before_action :check_staff

  def index
    @interview_types = InterviewType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interview_types }
    end
  end

  def show
    @interview_type = InterviewType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interview_type }
    end
  end

  def new
    @interview_type = InterviewType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview_type }
    end
  end

  def edit
    @interview_type = InterviewType.find(params[:id])
  end

  def create
    @interview_type = InterviewType.new(interview_type_params)

    respond_to do |format|
      if @interview_type.save
        format.html { redirect_to @interview_type, notice: "Interview type was successfully created." }
        format.json { render json: @interview_type, status: :created, location: @interview_type }
      else
        format.html { render action: "new" }
        format.json { render json: @interview_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @interview_type = InterviewType.find(params[:id])

    respond_to do |format|
      if @interview_type.update(interview_type_params)
        format.html { redirect_to @interview_type, notice: "Interview type was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interview_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @interview_type = InterviewType.find(params[:id])
    @interview_type.destroy

    respond_to do |format|
      format.html { redirect_to interview_types_url }
      format.json { head :no_content }
    end
  end

  private

  def interview_type_params
    params.require(:interview_type).permit(:code, :name, :description)
  end
end
