class AssociatedBudgetsController < ApplicationController
  # GET /associated_budgets
  # GET /associated_budgets.json
  def index
    @associated_budgets = AssociatedBudget.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @associated_budgets }
    end
  end

  # GET /associated_budgets/1
  # GET /associated_budgets/1.json
  def show
    @associated_budget = AssociatedBudget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @associated_budget }
    end
  end

  # GET /associated_budgets/new
  # GET /associated_budgets/new.json
  def new
    @associated_budget = AssociatedBudget.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @associated_budget }
    end
  end

  # GET /associated_budgets/1/edit
  def edit
    @associated_budget = AssociatedBudget.find(params[:id])
  end

  # POST /associated_budgets
  # POST /associated_budgets.json
  def create
    @associated_budget = AssociatedBudget.new(params[:associated_budget])

    respond_to do |format|
      if @associated_budget.save
        format.html { redirect_to @associated_budget, notice: 'Associated budget was successfully created.' }
        format.json { render json: @associated_budget, status: :created, location: @associated_budget }
      else
        format.html { render action: "new" }
        format.json { render json: @associated_budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /associated_budgets/1
  # PUT /associated_budgets/1.json
  def update
    @associated_budget = AssociatedBudget.find(params[:id])

    respond_to do |format|
      if @associated_budget.update_attributes(params[:associated_budget])
        format.html { redirect_to @associated_budget, notice: 'Associated budget was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @associated_budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /associated_budgets/1
  # DELETE /associated_budgets/1.json
  def destroy
    @associated_budget = AssociatedBudget.find(params[:id])
    @associated_budget.destroy

    respond_to do |format|
      format.html { redirect_to associated_budgets_url }
      format.json { head :no_content }
    end
  end
end
