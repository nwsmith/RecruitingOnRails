class GendersController < ApplicationController
  before_action :check_staff

  def index
    @genders = Gender.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @genders }
    end
  end

  def show
    @gender = Gender.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gender }
    end
  end

  def new
    @gender = Gender.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gender }
    end
  end

  def edit
    @gender = Gender.find(params[:id])
  end

  def create
    @gender = Gender.new(gender_params)

    respond_to do |format|
      if @gender.save
        format.html { redirect_to @gender, notice: "Gender was successfully created." }
        format.json { render json: @gender, status: :created, location: @gender }
      else
        format.html { render action: "new" }
        format.json { render json: @gender.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @gender = Gender.find(params[:id])

    respond_to do |format|
      if @gender.update(gender_params)
        format.html { redirect_to @gender, notice: "Gender was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gender.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @gender = Gender.find(params[:id])
    @gender.destroy

    respond_to do |format|
      format.html { redirect_to genders_url }
      format.json { head :no_content }
    end
  end

  private

  def gender_params
    params.require(:gender).permit(:code, :name, :description)
  end
end
