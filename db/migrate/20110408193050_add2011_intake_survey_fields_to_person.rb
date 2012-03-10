class Add2011IntakeSurveyFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :other_how_did_you_hear, :string
    add_column :people, :can_send_texts, :boolean
    add_column :people, :can_receive_texts, :boolean
    add_column :people, :unlimited_texting, :boolean
    add_column :people, :college_bound_scholarship, :boolean
    add_column :people, :other_college_programs, :string
  end

  def self.down
    remove_column :people, :other_college_programs
    remove_column :people, :college_bound_scholarship
    remove_column :people, :unlimited_texting
    remove_column :people, :can_receive_texts
    remove_column :people, :can_send_texts
    remove_column :people, :other_how_did_you_hear
  end
end
