class DiaryEntryTypesController < ApplicationController
  before_action :set_diary_entry_type, only: [:show, :edit, :update, :destroy]

  # GET /diary_entry_types
  def index
    @diary_entry_types = DiaryEntryType.all
  end

  # GET /diary_entry_types/1
  def show
  end

  # GET /diary_entry_types/new
  def new
    @diary_entry_type = DiaryEntryType.new
  end

  # GET /diary_entry_types/1/edit
  def edit
  end

  # POST /diary_entry_types
  def create
    @diary_entry_type = DiaryEntryType.new(diary_entry_type_params)

    if @diary_entry_type.save
      redirect_to @diary_entry_type, notice: 'Diary entry type was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /diary_entry_types/1
  def update
    if @diary_entry_type.update(diary_entry_type_params)
      redirect_to @diary_entry_type, notice: 'Diary entry type was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /diary_entry_types/1
  def destroy
    @diary_entry_type.destroy
    redirect_to diary_entry_types_url, notice: 'Diary entry type was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diary_entry_type
      @diary_entry_type = DiaryEntryType.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def diary_entry_type_params
      params.require(:diary_entry_type).permit(:code, :name, :description, :positive, :negative)
    end
end
