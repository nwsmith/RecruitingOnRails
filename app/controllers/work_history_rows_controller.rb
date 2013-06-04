class WorkHistoryRowsController < ApplicationController
  # GET /work_history_rows
  # GET /work_history_rows.json
  def index
    @work_history_rows = WorkHistoryRow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @work_history_rows }
    end
  end

  # GET /work_history_rows/1
  # GET /work_history_rows/1.json
  def show
    @work_history_row = WorkHistoryRow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @work_history_row }
    end
  end

  # GET /work_history_rows/new
  # GET /work_history_rows/new.json
  def new
    @work_history_row = WorkHistoryRow.new
    @work_history_row.candidate_id = params[:candidate_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @work_history_row }
    end
  end

  # GET /work_history_rows/1/edit
  def edit
    @work_history_row = WorkHistoryRow.find(params[:id])
  end

  # POST /work_history_rows
  # POST /work_history_rows.json
  def create
    @work_history_row = WorkHistoryRow.new(params[:work_history_row])

    respond_to do |format|
      if @work_history_row.save
        format.html { redirect_to @work_history_row, notice: 'Work history row was successfully created.' }
        format.json { render json: @work_history_row, status: :created, location: @work_history_row }
      else
        format.html { render action: "new" }
        format.json { render json: @work_history_row.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /work_history_rows/1
  # PUT /work_history_rows/1.json
  def update
    @work_history_row = WorkHistoryRow.find(params[:id])

    respond_to do |format|
      if @work_history_row.update_attributes(params[:work_history_row])
        format.html { redirect_to @work_history_row, notice: 'Work history row was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @work_history_row.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_history_rows/1
  # DELETE /work_history_rows/1.json
  def destroy
    @work_history_row = WorkHistoryRow.find(params[:id])
    @work_history_row.destroy

    respond_to do |format|
      format.html { redirect_to work_history_rows_url }
      format.json { head :no_content }
    end
  end
end
