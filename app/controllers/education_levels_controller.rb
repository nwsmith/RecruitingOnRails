class EducationLevelsController < ApplicationController
  before_action :check_staff

  def index
    @education_levels = EducationLevel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @education_levels }
    end
  end

  def show
    @education_level = EducationLevel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @education_level }
    end
  end

  def new
    @education_level = EducationLevel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @education_level }
    end
  end

  def edit
    @education_level = EducationLevel.find(params[:id])
  end

  def create
    @education_level = EducationLevel.new(education_level_params)

    respond_to do |format|
      if @education_level.save
        format.html { redirect_to @education_level, notice: 'Education level was successfully created.' }
        format.json { render json: @education_level, status: :created, location: @education_level }
      else
        format.html { render action: "new" }
        format.json { render json: @education_level.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @education_level = EducationLevel.find(params[:id])

    respond_to do |format|
      if @education_level.update(education_level_params)
        format.html { redirect_to @education_level, notice: 'Education level was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @education_level.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @education_level = EducationLevel.find(params[:id])
    @education_level.destroy

    respond_to do |format|
      format.html { redirect_to education_levels_url }
      format.json { head :no_content }
    end
  end

  private

  def education_level_params
    params.require(:education_level).permit(:code, :name, :description)
  end
end
