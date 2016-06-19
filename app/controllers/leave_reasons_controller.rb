class LeaveReasonsController < ApplicationController
  # GET /leave_reasons
  # GET /leave_reasons.json
  def index
    @leave_reasons = LeaveReason.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @leave_reasons }
    end
  end

  # GET /leave_reasons/1
  # GET /leave_reasons/1.json
  def show
    @leave_reason = LeaveReason.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @leave_reason }
    end
  end

  # GET /leave_reasons/new
  # GET /leave_reasons/new.json
  def new
    @leave_reason = LeaveReason.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @leave_reason }
    end
  end

  # GET /leave_reasons/1/edit
  def edit
    @leave_reason = LeaveReason.find(params[:id])
  end

  # POST /leave_reasons
  # POST /leave_reasons.json
  def create
    @leave_reason = LeaveReason.new(params[:leave_reason])

    respond_to do |format|
      if @leave_reason.save
        format.html { redirect_to @leave_reason, notice: 'Leave reason was successfully created.' }
        format.json { render json: @leave_reason, status: :created, location: @leave_reason }
      else
        format.html { render action: "new" }
        format.json { render json: @leave_reason.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /leave_reasons/1
  # PUT /leave_reasons/1.json
  def update
    @leave_reason = LeaveReason.find(params[:id])

    respond_to do |format|
      if @leave_reason.update_attributes(params[:leave_reason])
        format.html { redirect_to @leave_reason, notice: 'Leave reason was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @leave_reason.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leave_reasons/1
  # DELETE /leave_reasons/1.json
  def destroy
    @leave_reason = LeaveReason.find(params[:id])
    @leave_reason.destroy

    respond_to do |format|
      format.html { redirect_to leave_reasons_url }
      format.json { head :no_content }
    end
  end
end
