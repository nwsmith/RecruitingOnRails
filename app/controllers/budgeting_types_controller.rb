class BudgetingTypesController < ApplicationController
  before_action :check_staff

  def index
    @budgeting_types = BudgetingType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @budgeting_types }
    end
  end

  def show
    @budgeting_type = BudgetingType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @budgeting_type }
    end
  end

  def new
    @budgeting_type = BudgetingType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @budgeting_type }
    end
  end

  def edit
    @budgeting_type = BudgetingType.find(params[:id])
  end

  def create
    @budgeting_type = BudgetingType.new(budgeting_type_params)

    respond_to do |format|
      if @budgeting_type.save
        format.html { redirect_to @budgeting_type, notice: "Budgeting type was successfully created." }
        format.json { render json: @budgeting_type, status: :created, location: @budgeting_type }
      else
        format.html { render action: "new" }
        format.json { render json: @budgeting_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @budgeting_type = BudgetingType.find(params[:id])

    respond_to do |format|
      if @budgeting_type.update(budgeting_type_params)
        format.html { redirect_to @budgeting_type, notice: "Budgeting type was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @budgeting_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @budgeting_type = BudgetingType.find(params[:id])
    @budgeting_type.destroy

    respond_to do |format|
      format.html { redirect_to budgeting_types_url }
      format.json { head :no_content }
    end
  end

  private

  def budgeting_type_params
    params.require(:budgeting_type).permit(:code, :name, :description)
  end
end
