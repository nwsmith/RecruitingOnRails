class CreateReferenceChecks < ActiveRecord::Migration
  def up
    create_table :reference_checks do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :notes
      t.references :candidate
      t.references :review_result
    end

    execute <<-SQL
      ALTER TABLE reference_checks
        ADD CONSTRAINT fk_candidate
        FOREIGN KEY (candidate_id)
        REFERENCES candidates(id)
    SQL

    execute <<-SQL
      ALTER TABLE reference_checks
        ADD CONSTRAINT fk_ref_rev_res
        FOREIGN KEY (review_result_id)
        REFERENCES review_results(id)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE reference_checks
        DROP FOREIGN KEY fk_candidate
    SQL

    execute <<-SQL
      ALTER TABLE reference_checks
        DROP FOREIGN KEY fk_ref_ref_res
    SQL

    drop_table :reference_checks
  end
end
