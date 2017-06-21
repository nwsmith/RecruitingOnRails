class BudgetingTypesController < ApplicationController
  # GET /budgeting_types
  # GET /budgeting_types.json
  def index
    @budgeting_types = BudgetingType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @budgeting_types }
    end
  end

  # GET /budgeting_types/1
  # GET /budgeting_types/1.json
  def show
    @budgeting_type = BudgetingType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @budgeting_type }
    end
  end

  # GET /budgeting_types/new
  # GET /budgeting_types/new.json
  def new
    @budgeting_type = BudgetingType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @budgeting_type }
    end
  end

  # GET /budgeting_types/1/edit
  def edit
    @budgeting_type = BudgetingType.find(params[:id])
  end

  # POST /budgeting_types
  # POST /budgeting_types.json
  def create
    @budgeting_type = BudgetingType.new(user_params)

    respond_to do |format|
      if @budgeting_type.save
        format.html { redirect_to @budgeting_type, notice: 'Budgeting type was successfully created.' }
        format.json { render json: @budgeting_type, status: :created, location: @budgeting_type }
      else
        format.html { render action: "new" }
        format.json { render json: @budgeting_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /budgeting_types/1
  # PUT /budgeting_types/1.json
  def update
    @budgeting_type = BudgetingType.find(params[:id])

    respond_to do |format|
      if @budgeting_type.update_attributes(user_params)
        format.html { redirect_to @budgeting_type, notice: 'Budgeting type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @budgeting_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /budgeting_types/1
  # DELETE /budgeting_types/1.json
  def destroy
    @budgeting_type = BudgetingType.find(params[:id])
    @budgeting_type.destroy

    respond_to do |format|
      format.html { redirect_to budgeting_types_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:budgeting_type).permit!
  end
end
