class CodeSubmissionReviewsController < ApplicationController
  # GET /code_submission_reviews
  # GET /code_submission_reviews.json
  def index
    @code_submission_reviews = CodeSubmissionReview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @code_submission_reviews }
    end
  end

  # GET /code_submission_reviews/1
  # GET /code_submission_reviews/1.json
  def show
    @code_submission_review = CodeSubmissionReview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @code_submission_review }
    end
  end

  # GET /code_submission_reviews/new
  # GET /code_submission_reviews/new.json
  def new
    @code_submission_review = CodeSubmissionReview.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @code_submission_review }
    end
  end

  # GET /code_submission_reviews/1/edit
  def edit
    @code_submission_review = CodeSubmissionReview.find(params[:id])
  end

  # POST /code_submission_reviews
  # POST /code_submission_reviews.json
  def create
    @code_submission_review = CodeSubmissionReview.new(params[:code_submission_review])

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

  # PUT /code_submission_reviews/1
  # PUT /code_submission_reviews/1.json
  def update
    @code_submission_review = CodeSubmissionReview.find(params[:id])

    respond_to do |format|
      if @code_submission_review.update_attributes(params[:code_submission_review])
        format.html { redirect_to @code_submission_review, notice: 'Code submission review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @code_submission_review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_submission_reviews/1
  # DELETE /code_submission_reviews/1.json
  def destroy
    @code_submission_review = CodeSubmissionReview.find(params[:id])
    @code_submission_review.destroy

    respond_to do |format|
      format.html { redirect_to code_submission_reviews_url }
      format.json { head :no_content }
    end
  end
end
