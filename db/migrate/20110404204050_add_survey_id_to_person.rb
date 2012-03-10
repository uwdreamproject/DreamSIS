class AddSurveyIdToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :survey_id, :string
  end

  def self.down
    remove_column :people, :survey_id
  end
end
