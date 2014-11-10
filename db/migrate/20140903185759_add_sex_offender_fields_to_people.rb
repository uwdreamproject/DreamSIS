class AddSexOffenderFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :sex_offender_check_run_at, :datetime
    add_column :people, :sex_offender_check_result, :string
  end

  def self.down
    remove_column :people, :sex_offender_check_run_at
    remove_column :people, :sex_offender_check_result
  end
end
