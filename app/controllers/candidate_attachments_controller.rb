class CandidateAttachmentsController < ApplicationController
  # GET /candidate_attachments
  # GET /candidate_attachments.json
  def index
    @candidate_attachments = CandidateAttachment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidate_attachments }
    end
  end

  # GET /candidate_attachments/1
  # GET /candidate_attachments/1.json
  def show
    @candidate_attachment = CandidateAttachment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate_attachment }
    end
  end

  # GET /candidate_attachments/new
  # GET /candidate_attachments/new.json
  def new
    @candidate_attachment = CandidateAttachment.new
    @candidate_attachment.candidate_id = params[:candidate_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate_attachment }
    end
  end

  # GET /candidate_attachments/1/edit
  def edit
    @candidate_attachment = CandidateAttachment.find(params[:id])
  end

  # POST /candidate_attachments
  # POST /candidate_attachments.json
  def create
    @candidate_attachment = CandidateAttachment.new(user_params)

    respond_to do |format|
      if @candidate_attachment.save
        format.html { redirect_to @candidate_attachment, notice: 'Candidate attachment was successfully created.' }
        format.json { render json: @candidate_attachment, status: :created, location: @candidate_attachment }
      else
        format.html { render action: "new" }
        format.json { render json: @candidate_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /candidate_attachments/1
  # PUT /candidate_attachments/1.json
  def update
    @candidate_attachment = CandidateAttachment.find(params[:id])

    respond_to do |format|
      if @candidate_attachment.update_attributes(user_params)
        format.html { redirect_to @candidate_attachment, notice: 'Candidate attachment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @candidate_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /candidate_attachments/1
  # DELETE /candidate_attachments/1.json
  def destroy
    @candidate_attachment = CandidateAttachment.find(params[:id])
    @candidate_attachment.destroy

    respond_to do |format|
      format.html { redirect_to candidate_attachments_url }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    params.require(:candidate_attachment).permit!
  end
end
