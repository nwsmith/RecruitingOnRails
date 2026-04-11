class CodeSubmissionReviewsController < ApplicationController
  def index
    @code_submission_reviews = CodeSubmissionReview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @code_submission_reviews }
    end
  end

  def show
    @code_submission_review = CodeSubmissionReview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @code_submission_review }
    end
  end

  def new
    @code_submission_review = CodeSubmissionReview.new
    @code_submission_review.code_submission_id = params[:code_submission_id]
    @code_submission_review.user_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @code_submission_review }
    end
  end

  def edit
    @code_submission_review = CodeSubmissionReview.find(params[:id])
  end

  def create
    @code_submission_review = CodeSubmissionReview.new(code_submission_review_params)

    respond_to do |format|
      if @code_submission_review.save
        format.html { redirect_to @code_submission_review, notice: 'Code submission review was successfully created.' }
        format.json { render json: @code_submission_review, status: :created, location: @code_submission_review }
      else
        format.html { render action: "new" }
        format.json { render json: @code_submission_review.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @code_submission_review = CodeSubmissionReview.find(params[:id])

    respond_to do |format|
      if @code_submission_review.update(code_submission_review_params)
        format.html { redirect_to @code_submission_review, notice: 'Code submission review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @code_submission_review.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @code_submission_review = CodeSubmissionReview.find(params[:id])
    @code_submission_review.destroy

    respond_to do |format|
      format.html { redirect_to code_submission_reviews_url }
      format.json { head :no_content }
    end
  end

  private

  def code_submission_review_params
    params.require(:code_submission_review).permit(:code_submission_id, :user_id, :review_result_id, :notes)
  end
end
