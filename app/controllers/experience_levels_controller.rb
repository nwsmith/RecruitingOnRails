class ExperienceLevelsController < ApplicationController
  before_action :check_staff

  def index
    @experience_levels = ExperienceLevel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @experience_levels }
    end
  end

  def show
    @experience_level = ExperienceLevel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @experience_level }
    end
  end

  def new
    @experience_level = ExperienceLevel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @experience_level }
    end
  end

  def edit
    @experience_level = ExperienceLevel.find(params[:id])
  end

  def create
    @experience_level = ExperienceLevel.new(experience_level_params)

    respond_to do |format|
      if @experience_level.save
        format.html { redirect_to @experience_level, notice: 'Experience level was successfully created.' }
        format.json { render json: @experience_level, status: :created, location: @experience_level }
      else
        format.html { render action: "new" }
        format.json { render json: @experience_level.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @experience_level = ExperienceLevel.find(params[:id])

    respond_to do |format|
      if @experience_level.update(experience_level_params)
        format.html { redirect_to @experience_level, notice: 'Experience level was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @experience_level.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @experience_level = ExperienceLevel.find(params[:id])
    @experience_level.destroy

    respond_to do |format|
      format.html { redirect_to experience_levels_url }
      format.json { head :no_content }
    end
  end

  private

  def experience_level_params
    params.require(:experience_level).permit(:code, :name, :description, :color)
  end
end
