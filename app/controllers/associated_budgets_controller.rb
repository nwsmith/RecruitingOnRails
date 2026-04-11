class AssociatedBudgetsController < ApplicationController
  before_action :check_staff

  def index
    @associated_budgets = AssociatedBudget.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @associated_budgets }
    end
  end

  def show
    @associated_budget = AssociatedBudget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @associated_budget }
    end
  end

  def new
    @associated_budget = AssociatedBudget.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @associated_budget }
    end
  end

  def edit
    @associated_budget = AssociatedBudget.find(params[:id])
  end

  def create
    @associated_budget = AssociatedBudget.new(associated_budget_params)

    respond_to do |format|
      if @associated_budget.save
        format.html { redirect_to @associated_budget, notice: "Associated budget was successfully created." }
        format.json { render json: @associated_budget, status: :created, location: @associated_budget }
      else
        format.html { render action: "new" }
        format.json { render json: @associated_budget.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @associated_budget = AssociatedBudget.find(params[:id])

    respond_to do |format|
      if @associated_budget.update(associated_budget_params)
        format.html { redirect_to @associated_budget, notice: "Associated budget was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @associated_budget.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @associated_budget = AssociatedBudget.find(params[:id])
    @associated_budget.destroy

    respond_to do |format|
      format.html { redirect_to associated_budgets_url }
      format.json { head :no_content }
    end
  end

  private

  def associated_budget_params
    params.require(:associated_budget).permit(:code, :name, :description, :active)
  end
end
