class CreateReviewResults < ActiveRecord::Migration
  def up
    create_table :review_results do |t|
      t.string :code
      t.string :name
      t.string :description
      t.boolean :is_approval
      t.boolean :is_disapproval
    end

    change_table :interview_reviews do |t|
      t.references :review_result
    end

    change_table :code_submission_reviews do |t|
      t.references :review_result
    end

    execute <<-SQL
      ALTER TABLE interview_reviews
        ADD CONSTRAINT fk_interview_rev_res
        FOREIGN KEY (review_result_id)
        REFERENCES review_results(id)
    SQL

    execute <<-SQL
      ALTER TABLE code_submission_reviews
        ADD CONSTRAINT fk_submission_rev_res
        FOREIGN KEY (review_result_id)
        REFERENCES review_results(id)
    SQL

    approved = ReviewResult.create({code: 'APPROVED', name: 'Thumbs Up', is_approval: true, is_disapproval: false})
    unapproved = ReviewResult.create({code: 'REJECTED', name: 'Thumbs Down', is_approval: false, is_disapproval: true})
    no_review = ReviewResult.create({code: 'NO_REVIEW', name: 'N/A', is_approval: false, is_disapproval: false})

    InterviewReview.all.each do |interview_review|
      if interview_review.approved?
        interview_review.review_result_id = approved.id
      elsif interview_review.unapproved?
        interview_review.review_result_id = unapproved.id
      else
        interview_review.review_result_id = no_review
      end
      interview_review.save!
    end

    CodeSubmissionReview.all.each do |submission_review|
      if submission_review.approved?
        submission_review.review_result_id = approved.id
      elsif submission_review.unapproved?
        submission_review.review_result_id = unapproved.id
      else
        submission_review.review_result_id = no_review
      end
      submission_review.save!
    end

    remove_column :interview_reviews, :approved
    remove_column :interview_reviews, :unapproved
    remove_column :code_submission_reviews, :approved
    remove_column :code_submission_reviews, :unapproved
  end

  def down
    add_column :interview_reviews, :approved, :boolean
    add_column :interview_reviews, :unapproved, :boolean
    add_column :code_submission_reviews, :approved, :boolean
    add_column :code_submission_reviews, :unapproved, :boolean

    approved = ReviewResult.find_by_code('APPROVED')
    unapproved = ReviewResult.find_by_code('REJECTED')

    # The "no review case" would be covered by neither column being set to true, which was the old (ugly) way
    InterviewReview.all.each do |interview_review|
      interview_review.approved = true if !interview_review.review_result.nil? && interview_review.review_result.id == approved.id
      interview_review.unapproved = true if !interview_review.review_result.nil? && interview_review.review_result.id == unapproved.id
      interview_review.save!
    end

    CodeSubmissionReview.all.each do |submission_review|
      submission_review.approved = true if !submission_review.review_result.nil? && submission_review.review_result.id == approved.id
      submission_review.unapproved = true if !submission_review.review_result.nil? && submission_review.review_result.id == unapproved.id
      submission_review.save!
    end

    execute <<-SQL
      ALTER TABLE code_submission_reviews
        DROP FOREIGN KEY fk_submission_rev_res
    SQL

    execute <<-SQL
      ALTER TABLE interview_reviews
        DROP FOREIGN KEY fk_interview_rev_res
    SQL

    remove_column :code_submission_reviews, :review_result_id
    remove_column :interview_reviews, :review_result_id

    drop_table :review_results
  end
end
