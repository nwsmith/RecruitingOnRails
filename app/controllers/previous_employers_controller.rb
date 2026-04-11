class PreviousEmployersController < ApplicationController
  before_action :check_staff

  def index
    @previous_employers = PreviousEmployer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @previous_employers }
    end
  end

  def show
    @previous_employer = PreviousEmployer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @previous_employer }
    end
  end

  def new
    @previous_employer = PreviousEmployer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @previous_employer }
    end
  end

  def edit
    @previous_employer = PreviousEmployer.find(params[:id])
  end

  def create
    @previous_employer = PreviousEmployer.new(previous_employer_params)

    respond_to do |format|
      if @previous_employer.save
        format.html { redirect_to @previous_employer, notice: 'Previous employer was successfully created.' }
        format.json { render json: @previous_employer, status: :created, location: @previous_employer }
      else
        format.html { render action: "new" }
        format.json { render json: @previous_employer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @previous_employer = PreviousEmployer.find(params[:id])

    respond_to do |format|
      if @previous_employer.update(previous_employer_params)
        format.html { redirect_to @previous_employer, notice: 'Previous employer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @previous_employer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @previous_employer = PreviousEmployer.find(params[:id])
    @previous_employer.destroy

    respond_to do |format|
      format.html { redirect_to previous_employers_url }
      format.json { head :no_content }
    end
  end

  private

  def previous_employer_params
    params.require(:previous_employer).permit(:code, :name, :description)
  end
end
