class ReviewResultsController < ApplicationController
  # GET /review_results
  # GET /review_results.json
  def index
    @review_results = ReviewResult.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @review_results }
    end
  end

  # GET /review_results/1
  # GET /review_results/1.json
  def show
    @review_result = ReviewResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @review_result }
    end
  end

  # GET /review_results/new
  # GET /review_results/new.json
  def new
    @review_result = ReviewResult.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @review_result }
    end
  end

  # GET /review_results/1/edit
  def edit
    @review_result = ReviewResult.find(params[:id])
  end

  # POST /review_results
  # POST /review_results.json
  def create
    @review_result = ReviewResult.new(user_params)

    respond_to do |format|
      if @review_result.save
        format.html { redirect_to @review_result, notice: 'Review result was successfully created.' }
        format.json { render json: @review_result, status: :created, location: @review_result }
      else
        format.html { render action: "new" }
        format.json { render json: @review_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /review_results/1
  # PUT /review_results/1.json
  def update
    @review_result = ReviewResult.find(params[:id])

    respond_to do |format|
      if @review_result.update_attributes(user_params)
        format.html { redirect_to @review_result, notice: 'Review result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @review_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /review_results/1
  # DELETE /review_results/1.json
  def destroy
    @review_result = ReviewResult.find(params[:id])
    @review_result.destroy

    respond_to do |format|
      format.html { redirect_to review_results_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:review_result).permit!
  end
end
