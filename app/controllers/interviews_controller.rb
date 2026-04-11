class InterviewsController < ApplicationController
  def index
    return if check_staff

    @interviews = Interview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interviews }
    end
  end

  def show
    @interview = Interview.find(params[:id])
    return if check_candidate_access(@interview.candidate)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interview }
    end
  end

  def new
    @interview = Interview.new
    @interview.candidate_id = params[:candidate_id]
    return if check_candidate_access(Candidate.find_by(id: params[:candidate_id]))

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview }
    end
  end

  def edit
    @interview = Interview.find(params[:id])
    # check_candidate_access redirects internally if access is denied;
    # the implicit return nil is the desired behavior either way.
    check_candidate_access(@interview.candidate)
  end

  def create
    @interview = Interview.new(interview_params)
    return if check_candidate_access(@interview.candidate)

    respond_to do |format|
      if @interview.save
        format.html { redirect_to @interview, notice: "Interview was successfully created." }
        format.json { render json: @interview, status: :created, location: @interview }
      else
        format.html { render action: "new", status: :unprocessable_entity }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @interview = Interview.find(params[:id])
    return if check_candidate_access(@interview.candidate)

    respond_to do |format|
      if @interview.update(interview_params)
        format.html { redirect_to @interview, notice: "Interview was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit", status: :unprocessable_entity }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @interview = Interview.find(params[:id])
    return if check_candidate_access(@interview.candidate)

    @interview.destroy

    respond_to do |format|
      format.html { redirect_to interviews_url }
      format.json { head :no_content }
    end
  end

  private

  def interview_params
    params.require(:interview).permit(:candidate_id, :interview_type_id, :meeting_time, :notes)
  end
end
