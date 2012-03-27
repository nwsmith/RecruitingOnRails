class CodeProblemsController < ApplicationController
  # GET /code_problems
  # GET /code_problems.json
  def index
    @code_problems = CodeProblem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @code_problems }
    end
  end

  # GET /code_problems/1
  # GET /code_problems/1.json
  def show
    @code_problem = CodeProblem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @code_problem }
    end
  end

  # GET /code_problems/new
  # GET /code_problems/new.json
  def new
    @code_problem = CodeProblem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @code_problem }
    end
  end

  # GET /code_problems/1/edit
  def edit
    @code_problem = CodeProblem.find(params[:id])
  end

  # POST /code_problems
  # POST /code_problems.json
  def create
    @code_problem = CodeProblem.new(params[:code_problem])

    respond_to do |format|
      if @code_problem.save
        format.html { redirect_to @code_problem, notice: 'Code problem was successfully created.' }
        format.json { render json: @code_problem, status: :created, location: @code_problem }
      else
        format.html { render action: "new" }
        format.json { render json: @code_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /code_problems/1
  # PUT /code_problems/1.json
  def update
    @code_problem = CodeProblem.find(params[:id])

    respond_to do |format|
      if @code_problem.update_attributes(params[:code_problem])
        format.html { redirect_to @code_problem, notice: 'Code problem was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @code_problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /code_problems/1
  # DELETE /code_problems/1.json
  def destroy
    @code_problem = CodeProblem.find(params[:id])
    @code_problem.destroy

    respond_to do |format|
      format.html { redirect_to code_problems_url }
      format.json { head :no_content }
    end
  end
end
