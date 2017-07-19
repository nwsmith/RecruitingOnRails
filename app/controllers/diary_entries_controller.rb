class DiaryEntriesController < ApplicationController
  before_action :check_manager
  before_action :set_diary_entry, only: [:show, :edit, :update, :destroy]

  # GET /diary_entries
  def index
    @diary_entries = DiaryEntry.all
  end

  # GET /diary_entries/1
  def show
  end

  # GET /diary_entries/new
  def new
    @diary_entry = DiaryEntry.new
    @diary_entry.entry_date ||= Date.today
    @diary_entry.candidate_id = params[:candidate_id]
    @diary_entry.user_id = session[:user_id]
  end

  # GET /diary_entries/1/edit
  def edit
  end

  # POST /diary_entries
  def create
    @diary_entry = DiaryEntry.new(diary_entry_params)

    if @diary_entry.save
      redirect_to @diary_entry, notice: 'Diary entry was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /diary_entries/1
  def update
    if @diary_entry.update(diary_entry_params)
      redirect_to @diary_entry, notice: 'Diary entry was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /diary_entries/1
  def destroy
    @diary_entry.destroy
    redirect_to diary_entries_url, notice: 'Diary entry was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_diary_entry
      @diary_entry = DiaryEntry.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def diary_entry_params
      params.require(:diary_entry).permit(:entry_date, :notes, :candidate_id, :diary_entry_type_id, :user_id)
    end
end
