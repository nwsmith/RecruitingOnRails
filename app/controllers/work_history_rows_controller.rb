class WorkHistoryRowsController < ApplicationController
  def index
    return if check_staff

    @work_history_rows = WorkHistoryRow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @work_history_rows }
    end
  end

  def show
    @work_history_row = WorkHistoryRow.find(params[:id])
    return if check_candidate_access(@work_history_row.candidate)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @work_history_row }
    end
  end

  def new
    @work_history_row = WorkHistoryRow.new
    @work_history_row.candidate_id = params[:candidate_id]
    return if check_candidate_access(Candidate.find_by(id: params[:candidate_id]))

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @work_history_row }
    end
  end

  def edit
    @work_history_row = WorkHistoryRow.find(params[:id])
    return if check_candidate_access(@work_history_row.candidate)
  end

  def create
    @work_history_row = WorkHistoryRow.new(work_history_row_params)
    return if check_candidate_access(@work_history_row.candidate)

    respond_to do |format|
      if @work_history_row.save
        format.html { redirect_to @work_history_row, notice: 'Work history row was successfully created.' }
        format.json { render json: @work_history_row, status: :created, location: @work_history_row }
      else
        format.html { render action: "new", status: :unprocessable_entity }
        format.json { render json: @work_history_row.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @work_history_row = WorkHistoryRow.find(params[:id])
    return if check_candidate_access(@work_history_row.candidate)

    respond_to do |format|
      if @work_history_row.update(work_history_row_params)
        format.html { redirect_to @work_history_row, notice: 'Work history row was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit", status: :unprocessable_entity }
        format.json { render json: @work_history_row.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @work_history_row = WorkHistoryRow.find(params[:id])
    return if check_candidate_access(@work_history_row.candidate)

    @work_history_row.destroy

    respond_to do |format|
      format.html { redirect_to work_history_rows_url }
      format.json { head :no_content }
    end
  end

  private

  def work_history_row_params
    params.require(:work_history_row).permit(:candidate_id, :previous_employer_id, :start_date, :end_date)
  end
end
