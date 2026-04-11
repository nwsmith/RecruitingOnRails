class CodeSubmissionsController < ApplicationController
  def index
    return if check_staff

    @code_submissions = CodeSubmission.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @code_submissions }
    end
  end

  def show
    @code_submission = CodeSubmission.find(params[:id])
    return if check_candidate_access(@code_submission.candidate)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @code_submission }
    end
  end

  def new
    @code_submission = CodeSubmission.new
    @code_submission.candidate_id = params[:candidate_id]
    return if check_candidate_access(Candidate.find_by(id: params[:candidate_id]))

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @code_submission }
    end
  end

  def edit
    @code_submission = CodeSubmission.find(params[:id])
    return if check_candidate_access(@code_submission.candidate)
  end

  def create
    @code_submission = CodeSubmission.new(code_submission_params)
    return if check_candidate_access(@code_submission.candidate)

    respond_to do |format|
      if @code_submission.save
        format.html { redirect_to @code_submission, notice: 'Code submission was successfully created.' }
        format.json { render json: @code_submission, status: :created, location: @code_submission }
      else
        format.html { render action: "new", status: :unprocessable_entity }
        format.json { render json: @code_submission.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @code_submission = CodeSubmission.find(params[:id])
    return if check_candidate_access(@code_submission.candidate)

    respond_to do |format|
      if @code_submission.update(code_submission_params)
        format.html { redirect_to @code_submission, notice: 'Code submission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit", status: :unprocessable_entity }
        format.json { render json: @code_submission.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @code_submission = CodeSubmission.find(params[:id])
    return if check_candidate_access(@code_submission.candidate)

    @code_submission.destroy

    respond_to do |format|
      format.html { redirect_to code_submissions_url }
      format.json { head :no_content }
    end
  end

  private

  def code_submission_params
    params.require(:code_submission).permit(:candidate_id, :code_problem_id, :sent_date, :submission_date, :notes)
  end
end
