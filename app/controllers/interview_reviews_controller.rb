class InterviewReviewsController < ApplicationController
  # GET /interview_reviews
  # GET /interview_reviews.json
  def index
    @interview_reviews = InterviewReview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @interview_reviews }
    end
  end

  # GET /interview_reviews/1
  # GET /interview_reviews/1.json
  def show
    @interview_review = InterviewReview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interview_review }
    end
  end

  # GET /interview_reviews/new
  # GET /interview_reviews/new.json
  def new
    @interview_review = InterviewReview.new
    @interview_review.interview_id = params[:interview_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interview_review }
    end
  end

  # GET /interview_reviews/1/edit
  def edit
    @interview_review = InterviewReview.find(params[:id])
  end

  # POST /interview_reviews
  # POST /interview_reviews.json
  def create
    @interview_review = InterviewReview.new(params[:interview_review])

    respond_to do |format|
      if @interview_review.save
        format.html { redirect_to @interview_review, notice: 'Interview review was successfully created.' }
        format.json { render json: @interview_review, status: :created, location: @interview_review }
      else
        format.html { render action: "new" }
        format.json { render json: @interview_review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /interview_reviews/1
  # PUT /interview_reviews/1.json
  def update
    @interview_review = InterviewReview.find(params[:id])

    respond_to do |format|
      if @interview_review.update_attributes(params[:interview_review])
        format.html { redirect_to @interview_review, notice: 'Interview review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interview_review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interview_reviews/1
  # DELETE /interview_reviews/1.json
  def destroy
    @interview_review = InterviewReview.find(params[:id])
    @interview_review.destroy

    respond_to do |format|
      format.html { redirect_to interview_reviews_url }
      format.json { head :no_content }
    end
  end
end
