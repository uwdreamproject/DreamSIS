class CreateFinancialAidPackages < ActiveRecord::Migration
  def change
    create_table :financial_aid_packages do |t|
      t.integer :participant_id
      t.integer :college_application_id
      t.integer :academic_year
      t.money :cost_of_attendance
      t.string :cost_of_attendance_source
      t.money :expected_family_contribution
      t.money :grants_total
      t.money :loans_total
      t.money :work_study_total
      t.money :gap_total
      
      t.timestamps
    end
  end
end
