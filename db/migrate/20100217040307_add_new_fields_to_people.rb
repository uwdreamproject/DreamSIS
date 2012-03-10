class AddNewFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :not_attending_college, :boolean
    add_column :people, :intake_survey_date, :date
    add_column :people, :received_binder, :boolean
    add_column :people, :live_the_dream_recipient, :boolean
    add_column :people, :live_the_dream_nominee, :boolean
    add_column :people, :address_is_invalid, :boolean
    add_column :people, :email_is_invalid, :boolean
    add_column :people, :other_programs, :text
    add_column :people, :college_graduation_date, :date
    add_column :people, :target_participant, :boolean
    add_column :people, :not_target_participant, :boolean
    add_column :people, :inactive_explanation, :text
    add_column :people, :inactive_date, :datetime
  end

  def self.down
    remove_column :people, :inactive_date
    remove_column :people, :inactive_explanation
    remove_column :people, :not_target_participant
    remove_column :people, :target_participant
    remove_column :people, :college_graduation_date
    remove_column :people, :other_programs
    remove_column :people, :email_is_invalid
    remove_column :people, :address_is_invalid
    remove_column :people, :live_the_dream_nominee
    remove_column :people, :live_the_dream_recipient
    remove_column :people, :received_binder
    remove_column :people, :intake_survey_date
    remove_column :people, :not_attending_college
  end
end
