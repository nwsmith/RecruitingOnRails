class ReferenceChecksController < ApplicationController
  # Reference check feedback can be sensitive (e.g. "do not hire"
  # signals from past managers). Lock writes and reads to staff:
  # admin / manager / hr only. The candidate themselves should not
  # see what their references said about them, so we deliberately
  # do NOT use check_candidate_access here.
  before_action :check_staff

  # GET /reference_checks
  # GET /reference_checks.json
  def index
    @reference_checks = ReferenceCheck.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reference_checks }
    end
  end

  # GET /reference_checks/1
  # GET /reference_checks/1.json
  def show
    @reference_check = ReferenceCheck.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reference_check }
    end
  end

  # GET /reference_checks/new
  # GET /reference_checks/new.json
  def new
    @reference_check = ReferenceCheck.new
    @reference_check.candidate_id = params[:candidate_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reference_check }
    end
  end

  # GET /reference_checks/1/edit
  def edit
    @reference_check = ReferenceCheck.find(params[:id])
  end

  # POST /reference_checks
  # POST /reference_checks.json
  def create
    @reference_check = ReferenceCheck.new(user_params)

    respond_to do |format|
      if @reference_check.save
        format.html { redirect_to @reference_check, notice: 'Reference check was successfully created.' }
        format.json { render json: @reference_check, status: :created, location: @reference_check }
      else
        format.html { render action: "new", status: :unprocessable_entity }
        format.json { render json: @reference_check.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reference_checks/1
  # PUT /reference_checks/1.json
  def update
    @reference_check = ReferenceCheck.find(params[:id])

    respond_to do |format|
      if @reference_check.update(user_params)
        format.html { redirect_to @reference_check, notice: 'Reference check was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit", status: :unprocessable_entity }
        format.json { render json: @reference_check.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reference_checks/1
  # DELETE /reference_checks/1.json
  def destroy
    @reference_check = ReferenceCheck.find(params[:id])
    @reference_check.destroy

    respond_to do |format|
      format.html { redirect_to reference_checks_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:reference_check).permit(:candidate_id, :name, :title, :company, :phone, :email, :relationship, :years_known, :review_result_id, :notes)
  end
end
