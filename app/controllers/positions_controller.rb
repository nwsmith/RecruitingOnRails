class PositionsController < ApplicationController
  before_action :check_staff

  def index
    @positions = Position.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @positions }
    end
  end

  def show
    @position = Position.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @position }
    end
  end

  def new
    @position = Position.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @position }
    end
  end

  def edit
    @position = Position.find(params[:id])
  end

  def create
    @position = Position.new(position_params)

    respond_to do |format|
      if @position.save
        format.html { redirect_to @position, notice: 'Position was successfully created.' }
        format.json { render json: @position, status: :created, location: @position }
      else
        format.html { render action: "new" }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @position = Position.find(params[:id])

    respond_to do |format|
      if @position.update(position_params)
        format.html { redirect_to @position, notice: 'Position was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @position = Position.find(params[:id])
    @position.destroy

    respond_to do |format|
      format.html { redirect_to positions_url }
      format.json { head :no_content }
    end
  end

  private

  def position_params
    params.require(:position).permit(:code, :name, :description)
  end
end
