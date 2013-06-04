class PreviousEmployersController < ApplicationController
  # GET /previous_employers
  # GET /previous_employers.json
  def index
    @previous_employers = PreviousEmployer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @previous_employers }
    end
  end

  # GET /previous_employers/1
  # GET /previous_employers/1.json
  def show
    @previous_employer = PreviousEmployer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @previous_employer }
    end
  end

  # GET /previous_employers/new
  # GET /previous_employers/new.json
  def new
    @previous_employer = PreviousEmployer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @previous_employer }
    end
  end

  # GET /previous_employers/1/edit
  def edit
    @previous_employer = PreviousEmployer.find(params[:id])
  end

  # POST /previous_employers
  # POST /previous_employers.json
  def create
    @previous_employer = PreviousEmployer.new(params[:previous_employer])

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

  # PUT /previous_employers/1
  # PUT /previous_employers/1.json
  def update
    @previous_employer = PreviousEmployer.find(params[:id])

    respond_to do |format|
      if @previous_employer.update_attributes(params[:previous_employer])
        format.html { redirect_to @previous_employer, notice: 'Previous employer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @previous_employer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /previous_employers/1
  # DELETE /previous_employers/1.json
  def destroy
    @previous_employer = PreviousEmployer.find(params[:id])
    @previous_employer.destroy

    respond_to do |format|
      format.html { redirect_to previous_employers_url }
      format.json { head :no_content }
    end
  end
end
