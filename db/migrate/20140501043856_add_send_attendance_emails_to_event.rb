class AddSendAttendanceEmailsToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :send_attendance_emails, :boolean
    
    n = 0
    Event.find_in_batches do |events|
      events.each do |e|
        e.update_attribute(:send_attendance_emails, true)
        n = n+1
      end
    end
    puts "#{n} events updated."
  end

  def self.down
    remove_column :events, :send_attendance_emails
  end
end
