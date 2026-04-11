class ReferenceChecksController < ApplicationController
  # Reference check feedback can be sensitive (e.g. "do not hire"
  # signals from past managers). Lock writes and reads to staff:
  # admin / manager / hr only. The candidate themselves should not
  # see what their references said about them, so we deliberately
  # do NOT use check_candidate_access here.
  before_action :check_staff

  def index
    @reference_checks = ReferenceCheck.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reference_checks }
    end
  end

  def show
    @reference_check = ReferenceCheck.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reference_check }
    end
  end

  def new
    @reference_check = ReferenceCheck.new
    @reference_check.candidate_id = params[:candidate_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reference_check }
    end
  end

  def edit
    @reference_check = ReferenceCheck.find(params[:id])
  end

  def create
    @reference_check = ReferenceCheck.new(reference_check_params)

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

  def update
    @reference_check = ReferenceCheck.find(params[:id])

    respond_to do |format|
      if @reference_check.update(reference_check_params)
        format.html { redirect_to @reference_check, notice: 'Reference check was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit", status: :unprocessable_entity }
        format.json { render json: @reference_check.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reference_check = ReferenceCheck.find(params[:id])
    @reference_check.destroy

    respond_to do |format|
      format.html { redirect_to reference_checks_url }
      format.json { head :no_content }
    end
  end

  private

  def reference_check_params
    params.require(:reference_check).permit(:candidate_id, :name, :title, :company, :phone, :email, :relationship, :years_known, :review_result_id, :notes)
  end
end
