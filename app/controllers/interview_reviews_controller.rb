class InterviewReviewsController < ApplicationController
  def index
    @interview_reviews = InterviewReview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interview_reviews }
    end
  end

  def show
    @interview_review = InterviewReview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interview_review }
    end
  end

  def new
    @interview_review = InterviewReview.new
    @interview_review.interview_id = params[:interview_id]
    @interview_review.user_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview_review }
    end
  end

  def edit
    @interview_review = InterviewReview.find(params[:id])
  end

  def create
    @interview_review = InterviewReview.new(interview_review_params)

    respond_to do |format|
      if @interview_review.save
        format.html { redirect_to @interview_review, notice: "Interview review was successfully created." }
        format.json { render json: @interview_review, status: :created, location: @interview_review }
      else
        format.html { render action: "new" }
        format.json { render json: @interview_review.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @interview_review = InterviewReview.find(params[:id])

    respond_to do |format|
      if @interview_review.update(interview_review_params)
        format.html { redirect_to @interview_review, notice: "Interview review was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interview_review.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @interview_review = InterviewReview.find(params[:id])
    @interview_review.destroy

    respond_to do |format|
      format.html { redirect_to interview_reviews_url }
      format.json { head :no_content }
    end
  end

  private

  def interview_review_params
    params.require(:interview_review).permit(:interview_id, :user_id, :review_result_id, :notes)
  end
end
