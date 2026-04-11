class OfficeLocationsController < ApplicationController
  before_action :check_staff

  def index
    @office_locations = OfficeLocation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @office_locations }
    end
  end

  def show
    @office_location = OfficeLocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @office_location }
    end
  end

  def new
    @office_location = OfficeLocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @office_location }
    end
  end

  def edit
    @office_location = OfficeLocation.find(params[:id])
  end

  def create
    @office_location = OfficeLocation.new(office_location_params)

    respond_to do |format|
      if @office_location.save
        format.html { redirect_to @office_location, notice: 'Office location was successfully created.' }
        format.json { render json: @office_location, status: :created, location: @office_location }
      else
        format.html { render action: "new" }
        format.json { render json: @office_location.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @office_location = OfficeLocation.find(params[:id])

    respond_to do |format|
      if @office_location.update(office_location_params)
        format.html { redirect_to @office_location, notice: 'Office location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @office_location.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @office_location = OfficeLocation.find(params[:id])
    @office_location.destroy

    respond_to do |format|
      format.html { redirect_to office_locations_url }
      format.json { head :no_content }
    end
  end

  private

  def office_location_params
    params.require(:office_location).permit(:code, :name, :description)
  end
end
