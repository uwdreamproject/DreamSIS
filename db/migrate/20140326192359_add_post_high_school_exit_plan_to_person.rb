class AddPostHighSchoolExitPlanToPerson < ActiveRecord::Migration
  def self.up
		rename_column :people, :plans_after_high_school, :postsecondary_goal
		add_column :people, :postsecondary_plan, :string
		
		Participant.find(:all, :conditions => { :postsecondary_goal => "Community college" }).each do |p|
			p.update_attribute(:postsecondary_goal => "2-year college")
		end
  end

  def self.down
		remove_column :people, :postsecondary_plan
		rename_column :people, :postsecondary_goal, :plans_after_high_school

		Participant.find(:all, :conditions => { :plans_after_high_school => "2-year college" }).each do |p|
			p.update_attribute(:plans_after_high_school => "Community college")
		end
  end
end