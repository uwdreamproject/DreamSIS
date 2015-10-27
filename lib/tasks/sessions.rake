namespace :sessions do 
  
  desc "Delete sessions that are older than a specified age"
  task :sweep => :environment do
    Rails.logger = Logger.new(STDOUT)
    STDOUT.sync = true
    puts "Deleted #{Session.sweep!} aged sessions."
  end
  
end
