class CandidateAttachmentsController < ApplicationController
  def index
    return if check_staff

    @candidate_attachments = CandidateAttachment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidate_attachments }
    end
  end

  def show
    @candidate_attachment = CandidateAttachment.find(params[:id])
    return if check_candidate_access(@candidate_attachment.candidate)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate_attachment }
    end
  end

  def new
    @candidate_attachment = CandidateAttachment.new
    @candidate_attachment.candidate_id = params[:candidate_id]
    return if check_candidate_access(Candidate.find_by(id: params[:candidate_id]))

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate_attachment }
    end
  end

  def edit
    @candidate_attachment = CandidateAttachment.find(params[:id])
    # check_candidate_access redirects internally if access is denied;
    # the implicit return nil is the desired behavior either way.
    check_candidate_access(@candidate_attachment.candidate)
  end

  def create
    @candidate_attachment = CandidateAttachment.new(candidate_attachment_params)
    return if check_candidate_access(@candidate_attachment.candidate)

    respond_to do |format|
      if @candidate_attachment.save
        format.html { redirect_to @candidate_attachment, notice: "Candidate attachment was successfully created." }
        format.json { render json: @candidate_attachment, status: :created, location: @candidate_attachment }
      else
        format.html { render action: "new", status: :unprocessable_entity }
        format.json { render json: @candidate_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @candidate_attachment = CandidateAttachment.find(params[:id])
    return if check_candidate_access(@candidate_attachment.candidate)

    respond_to do |format|
      if @candidate_attachment.update(candidate_attachment_params)
        format.html { redirect_to @candidate_attachment, notice: "Candidate attachment was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit", status: :unprocessable_entity }
        format.json { render json: @candidate_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @candidate_attachment = CandidateAttachment.find(params[:id])
    return if check_candidate_access(@candidate_attachment.candidate)

    @candidate_attachment.destroy

    respond_to do |format|
      format.html { redirect_to candidate_attachments_url }
      format.json { head :no_content }
    end
  end

  private

  def candidate_attachment_params
    params.require(:candidate_attachment).permit(:notes, :candidate_id, :attachment)
  end
end
