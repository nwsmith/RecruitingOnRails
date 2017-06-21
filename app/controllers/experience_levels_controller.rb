class ExperienceLevelsController < ApplicationController
  # GET /experience_levels
  # GET /experience_levels.json
  def index
    @experience_levels = ExperienceLevel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @experience_levels }
    end
  end

  # GET /experience_levels/1
  # GET /experience_levels/1.json
  def show
    @experience_level = ExperienceLevel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @experience_level }
    end
  end

  # GET /experience_levels/new
  # GET /experience_levels/new.json
  def new
    @experience_level = ExperienceLevel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @experience_level }
    end
  end

  # GET /experience_levels/1/edit
  def edit
    @experience_level = ExperienceLevel.find(params[:id])
  end

  # POST /experience_levels
  # POST /experience_levels.json
  def create
    @experience_level = ExperienceLevel.new(user_params)

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

  # PUT /experience_levels/1
  # PUT /experience_levels/1.json
  def update
    @experience_level = ExperienceLevel.find(params[:id])

    respond_to do |format|
      if @experience_level.update_attributes(user_params)
        format.html { redirect_to @experience_level, notice: 'Experience level was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @experience_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /experience_levels/1
  # DELETE /experience_levels/1.json
  def destroy
    @experience_level = ExperienceLevel.find(params[:id])
    @experience_level.destroy

    respond_to do |format|
      format.html { redirect_to experience_levels_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:experience_level).permit!
  end
end
