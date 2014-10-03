class OfficeLocationsController < ApplicationController
  # GET /office_locations
  # GET /office_locations.json
  def index
    @office_locations = OfficeLocation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @office_locations }
    end
  end

  # GET /office_locations/1
  # GET /office_locations/1.json
  def show
    @office_location = OfficeLocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @office_location }
    end
  end

  # GET /office_locations/new
  # GET /office_locations/new.json
  def new
    @office_location = OfficeLocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @office_location }
    end
  end

  # GET /office_locations/1/edit
  def edit
    @office_location = OfficeLocation.find(params[:id])
  end

  # POST /office_locations
  # POST /office_locations.json
  def create
    @office_location = OfficeLocation.new(params[:office_location])

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

  # PUT /office_locations/1
  # PUT /office_locations/1.json
  def update
    @office_location = OfficeLocation.find(params[:id])

    respond_to do |format|
      if @office_location.update_attributes(params[:office_location])
        format.html { redirect_to @office_location, notice: 'Office location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @office_location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /office_locations/1
  # DELETE /office_locations/1.json
  def destroy
    @office_location = OfficeLocation.find(params[:id])
    @office_location.destroy

    respond_to do |format|
      format.html { redirect_to office_locations_url }
      format.json { head :no_content }
    end
  end
end
