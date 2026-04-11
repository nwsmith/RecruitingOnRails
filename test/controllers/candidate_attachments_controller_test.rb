require 'test_helper'

class CandidateAttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status = CandidateStatus.create!(code: 'PEND', name: 'Pending')
    @candidate = Candidate.create!(
      first_name: 'Jane',
      last_name: 'Doe',
      candidate_status: @status
    )
    @attachment = CandidateAttachment.create!(
      candidate: @candidate,
      notes: 'Initial resume'
    )
  end

  def login_as(username)
    post login_attempt_login_path, params: { username: username, password: 'password' }
  end

  def upload(content_type:, filename: 'resume.pdf', body: 'fake bytes')
    Rack::Test::UploadedFile.new(
      StringIO.new(body),
      content_type,
      original_filename: filename
    )
  end

  # ----- auth -----

  test 'unauthenticated index redirects to login' do
    get candidate_attachments_path
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'unauthenticated show redirects to login' do
    get candidate_attachment_path(@attachment)
    assert_redirected_to controller: 'login', action: 'index'
  end

  test 'unauthenticated create is rejected' do
    assert_no_difference -> { CandidateAttachment.count } do
      post candidate_attachments_path, params: {
        candidate_attachment: { candidate_id: @candidate.id, notes: 'x' }
      }
    end
    assert_redirected_to controller: 'login', action: 'index'
  end

  # ----- index / show -----

  test 'admin can list attachments' do
    login_as 'admin'
    get candidate_attachments_path
    assert_response :success
  end

  test 'admin can view an attachment' do
    login_as 'admin'
    get candidate_attachment_path(@attachment)
    assert_response :success
  end

  test 'admin can render the new attachment form' do
    login_as 'admin'
    get new_candidate_attachment_path(candidate_id: @candidate.id)
    assert_response :success
    assert_match %r{<option selected="selected" value="#{@candidate.id}">}, response.body
  end

  # ----- create with file uploads (Active Storage attached) -----

  test 'admin can create an attachment with a PDF upload' do
    login_as 'admin'
    assert_difference -> { CandidateAttachment.count }, 1 do
      post candidate_attachments_path, params: {
        candidate_attachment: {
          candidate_id: @candidate.id,
          notes: 'Resume',
          attachment: upload(content_type: 'application/pdf')
        }
      }
    end
    record = CandidateAttachment.last
    assert record.attachment.attached?, 'attachment should be persisted'
    assert_equal 'application/pdf', record.attachment.content_type
    assert_redirected_to candidate_attachment_path(record)
  end

  test 'create rejects an attachment with a disallowed content type' do
    login_as 'admin'
    assert_no_difference -> { CandidateAttachment.count } do
      post candidate_attachments_path, params: {
        candidate_attachment: {
          candidate_id: @candidate.id,
          notes: 'Bad upload',
          attachment: upload(content_type: 'text/html', filename: 'evil.html')
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test 'create accepts an attachment with allowed text/plain content type' do
    login_as 'admin'
    assert_difference -> { CandidateAttachment.count }, 1 do
      post candidate_attachments_path, params: {
        candidate_attachment: {
          candidate_id: @candidate.id,
          notes: 'Plain text',
          attachment: upload(content_type: 'text/plain', filename: 'notes.txt')
        }
      }
    end
  end

  # ----- update / destroy -----

  test 'admin can update notes' do
    login_as 'admin'
    patch candidate_attachment_path(@attachment),
          params: { candidate_attachment: { notes: 'Renamed' } }
    assert_redirected_to candidate_attachment_path(@attachment)
    assert_equal 'Renamed', @attachment.reload.notes
  end

  test 'admin can destroy an attachment' do
    login_as 'admin'
    assert_difference -> { CandidateAttachment.count }, -1 do
      delete candidate_attachment_path(@attachment)
    end
    assert_redirected_to candidate_attachments_path
  end

  # ----- per-candidate auth gates -----

  test 'regular user cannot list attachments (staff only)' do
    login_as 'regular'
    get candidate_attachments_path
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot view another candidates attachment' do
    login_as 'regular'
    get candidate_attachment_path(@attachment)
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot update another candidates attachment' do
    login_as 'regular'
    patch candidate_attachment_path(@attachment),
          params: { candidate_attachment: { notes: 'Hacked' } }
    assert_redirected_to controller: 'dashboard', action: 'index'
    assert_equal 'Initial resume', @attachment.reload.notes
  end

  test 'regular user cannot destroy another candidates attachment' do
    login_as 'regular'
    assert_no_difference -> { CandidateAttachment.count } do
      delete candidate_attachment_path(@attachment)
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'regular user cannot upload an attachment for another candidate' do
    login_as 'regular'
    assert_no_difference -> { CandidateAttachment.count } do
      post candidate_attachments_path, params: {
        candidate_attachment: {
          candidate_id: @candidate.id,
          notes: 'Hacked',
          attachment: upload(content_type: 'application/pdf')
        }
      }
    end
    assert_redirected_to controller: 'dashboard', action: 'index'
  end

  test 'self candidate user can view their own pending candidates attachment' do
    self_candidate = Candidate.create!(
      first_name: 'Self',
      last_name: 'Candidate',
      candidate_status: @status
    )
    own_attachment = CandidateAttachment.create!(
      candidate: self_candidate,
      notes: 'Own resume'
    )
    login_as 'self.candidate'
    get candidate_attachment_path(own_attachment)
    assert_response :success
  end
end
