# One-shot data migration: Paperclip → Active Storage for CandidateAttachment.
#
# Run order on production:
#
#   1. bin/rails db:migrate VERSION=20260410000001  # creates AS tables
#   2. PAPERCLIP_SOURCE_BUCKET=sum-resumes-prod \
#      bin/rails paperclip:migrate_to_active_storage
#   3. I_HAVE_MIGRATED_PAPERCLIP_DATA=yes bin/rails db:migrate
#      # runs 20260410000002 which drops the legacy columns
#
# This task expects the schema to STILL have the legacy Paperclip columns
# (attachment_file_name, attachment_content_type, attachment_file_size,
# attachment_updated_at). It reads them via raw SQL because the model class
# already declares `has_one_attached :attachment` and no longer has those
# columns in code.
#
# The task is idempotent: rows that already have an Active Storage attachment
# are skipped, so it can safely be re-run if interrupted.

namespace :paperclip do
  desc "Copy CandidateAttachment Paperclip S3 objects into Active Storage blobs"
  task migrate_to_active_storage: :environment do
    require "aws-sdk-s3"

    source_bucket = ENV["PAPERCLIP_SOURCE_BUCKET"] or abort <<~ERR
      PAPERCLIP_SOURCE_BUCKET is required (e.g. sum-resumes-prod). This is the
      legacy Paperclip-managed bucket the task will read FROM. The destination
      bucket is whatever Active Storage is configured to use in the current
      Rails environment (config/storage.yml + ENV["S3_BUCKET"]).
    ERR

    region = ENV.fetch("PAPERCLIP_SOURCE_REGION", "us-east-2")
    s3 = Aws::S3::Client.new(region: region)

    # Read directly from the table because the AR class no longer maps these
    # columns. This intentionally does NOT instantiate CandidateAttachment until
    # we're ready to attach, to avoid validation noise during the read pass.
    rows = ActiveRecord::Base.connection.select_all(<<~SQL)
      SELECT id, attachment_file_name, attachment_content_type
      FROM candidate_attachments
      WHERE attachment_file_name IS NOT NULL
    SQL

    if rows.empty?
      puts "No legacy Paperclip rows to migrate. Safe to set " \
           "I_HAVE_MIGRATED_PAPERCLIP_DATA=yes and run db:migrate."
      next
    end

    puts "Migrating #{rows.length} CandidateAttachment row(s) from " \
         "s3://#{source_bucket} to Active Storage..."

    migrated = 0
    skipped  = 0
    failed   = 0

    rows.each do |row|
      id           = row["id"]
      filename     = row["attachment_file_name"]
      content_type = row["attachment_content_type"]

      record = CandidateAttachment.find(id)

      if record.attachment.attached?
        skipped += 1
        puts "  ##{id} already has an Active Storage attachment, skipping"
        next
      end

      # Paperclip's default S3 path for `has_attached_file :attachment` on
      # CandidateAttachment is:
      #   candidate_attachments/attachments/:id_partition/original/:filename
      # where :id_partition is the zero-padded 9-digit id split into 3-char
      # groups (e.g. id=42 → "000/000/042").
      key = "candidate_attachments/attachments/#{id_partition(id)}/original/#{filename}"

      begin
        object = s3.get_object(bucket: source_bucket, key: key)
        record.attachment.attach(
          io: object.body,
          filename: filename,
          content_type: content_type
        )

        if record.attachment.attached?
          migrated += 1
          puts "  ##{id} migrated #{filename}"
        else
          failed += 1
          warn "  ##{id} attach call returned without attaching: " \
               "#{record.errors.full_messages.join(', ')}"
        end
      rescue Aws::S3::Errors::NoSuchKey
        failed += 1
        warn "  ##{id} object not found at s3://#{source_bucket}/#{key}"
      rescue => e
        failed += 1
        warn "  ##{id} #{e.class}: #{e.message}"
      end
    end

    puts ""
    puts "Done. migrated=#{migrated} skipped=#{skipped} failed=#{failed}"

    if failed > 0
      abort "FAILED: #{failed} rows could not be migrated. Investigate before " \
            "running the column-drop migration."
    end
  end

  # Paperclip's :id_partition: zero-pad to 9 digits, split into 3-char chunks.
  def id_partition(id)
    format("%09d", id.to_i).scan(/.{3}/).join("/")
  end
end
