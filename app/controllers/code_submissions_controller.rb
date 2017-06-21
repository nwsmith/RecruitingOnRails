class CodeSubmissionsController < ApplicationController
  # GET /code_submissions
  # GET /code_submissions.json
  def index
    @code_submissions = CodeSubmission.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @code_submissions }
    end
  end

  # GET /code_submissions/1
  # GET /code_submissions/1.json
  def show
    @code_submission = CodeSubmission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @code_submission }
    end
  end

  # GET /code_submissions/new
  # GET /code_submissions/new.json
  def new
    @code_submission = CodeSubmission.new
    @code_submission.candidate_id = params[:candidate_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @code_submission }
    end
  end

  # GET /code_submissions/1/edit
  def edit
    @code_submission = CodeSubmission.find(params[:id])
  end

  # POST /code_submissions
  # POST /code_submissions.json
  def create
    @code_submission = CodeSubmission.new(user_params)

    respond_to do |format|
      if @code_submission.save
        format.html { redirect_to @code_submission, notice: 'Code submission was successfully created.' }
        format.json { render json: @code_submission, status: :created, location: @code_submission }
      else
        format.html { render action: "new" }
        format.json { render json: @code_submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /code_submissions/1
  # PUT /code_submissions/1.json
  def update
    @code_submission = CodeSubmission.find(params[:id])

    respond_to do |format|
      if @code_submission.update_attributes(user_params)
        format.html { redirect_to @code_submission, notice: 'Code submission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @code_submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_submissions/1
  # DELETE /code_submissions/1.json
  def destroy
    @code_submission = CodeSubmission.find(params[:id])
    @code_submission.destroy

    respond_to do |format|
      format.html { redirect_to code_submissions_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:code_submission).permit!
  end
end
