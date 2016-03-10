class AddEmploymentStatusWeeklyHoursToPeople < ActiveRecord::Migration
  def change
    add_column :people, :employment_status, :boolean
    add_column :people, :weekly_hours, :integer
  end
end
