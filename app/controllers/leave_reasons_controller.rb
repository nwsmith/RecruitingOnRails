class LeaveReasonsController < ApplicationController
  before_action :check_staff

  def index
    @leave_reasons = LeaveReason.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @leave_reasons }
    end
  end

  def show
    @leave_reason = LeaveReason.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @leave_reason }
    end
  end

  def new
    @leave_reason = LeaveReason.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @leave_reason }
    end
  end

  def edit
    @leave_reason = LeaveReason.find(params[:id])
  end

  def create
    @leave_reason = LeaveReason.new(leave_reason_params)

    respond_to do |format|
      if @leave_reason.save
        format.html { redirect_to @leave_reason, notice: "Leave reason was successfully created." }
        format.json { render json: @leave_reason, status: :created, location: @leave_reason }
      else
        format.html { render action: "new" }
        format.json { render json: @leave_reason.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @leave_reason = LeaveReason.find(params[:id])

    respond_to do |format|
      if @leave_reason.update(leave_reason_params)
        format.html { redirect_to @leave_reason, notice: "Leave reason was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @leave_reason.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @leave_reason = LeaveReason.find(params[:id])
    @leave_reason.destroy

    respond_to do |format|
      format.html { redirect_to leave_reasons_url }
      format.json { head :no_content }
    end
  end

  private

  def leave_reason_params
    params.require(:leave_reason).permit(:code, :name, :description)
  end
end
