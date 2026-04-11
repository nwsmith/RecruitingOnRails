class ReviewResultsController < ApplicationController
  before_action :check_staff

  def index
    @review_results = ReviewResult.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @review_results }
    end
  end

  def show
    @review_result = ReviewResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @review_result }
    end
  end

  def new
    @review_result = ReviewResult.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @review_result }
    end
  end

  def edit
    @review_result = ReviewResult.find(params[:id])
  end

  def create
    @review_result = ReviewResult.new(review_result_params)

    respond_to do |format|
      if @review_result.save
        format.html { redirect_to @review_result, notice: "Review result was successfully created." }
        format.json { render json: @review_result, status: :created, location: @review_result }
      else
        format.html { render action: "new" }
        format.json { render json: @review_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @review_result = ReviewResult.find(params[:id])

    respond_to do |format|
      if @review_result.update(review_result_params)
        format.html { redirect_to @review_result, notice: "Review result was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @review_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @review_result = ReviewResult.find(params[:id])
    @review_result.destroy

    respond_to do |format|
      format.html { redirect_to review_results_url }
      format.json { head :no_content }
    end
  end

  private

  def review_result_params
    params.require(:review_result).permit(:code, :name, :description, :is_approval, :is_disapproval)
  end
end
