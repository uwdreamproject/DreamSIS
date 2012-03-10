class AddMentorAttributesToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :previous_participant_id, :integer
    add_column :people, :ferpa_agreement_signed_at, :datetime
    add_column :people, :background_check_run_at, :datetime
    add_column :people, :background_check_result, :string
    add_column :people, :risk_form_signed_at, :datetime
    add_column :people, :risk_form_signature, :string
    add_column :people, :reg_id, :string
    add_column :people, :uw_student_no, :string
    add_column :people, :uw_net_id, :string
  end

  def self.down
    remove_column :people, :uw_net_id
    remove_column :people, :uw_student_no
    remove_column :people, :reg_id
    remove_column :people, :risk_form_signature
    remove_column :people, :risk_form_signed_at
    remove_column :people, :background_check_result
    remove_column :people, :background_check_run_at
    remove_column :people, :ferpa_agreement_signed_at
    remove_column :people, :previous_participant_id
  end
end
