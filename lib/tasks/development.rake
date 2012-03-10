desc "Setup users and other environment settings for development and testing"
task :setup_development_users => :environment do
  puts "Setting up development users"
  puts "\nAdmin users:"
  admin_users =   { 'matt' => { :password => 'mattmatt', :person_id => 104 }, 
                    'equinol' => { :password => '1232321'},
                    'joshlin' => { :password => 'joshjosh' } 
                  }
  pp admin_users

  puts "\nStudent users:"
  student_users = { 'mattstudent' => { :password => 'mattmatt', :student_no => "0330463" },
                    'equinolstudent' => { :password => '1232321', :student_no => "0721257" },
                    'samstudent' => { :password => 'samsam', :student_no => "0622640" },
                    'joshstudent' => { :password => 'joshjosh', :student_no => "0842474" }
                  }
  pp student_users
  admin_users.each do |login, options|
    u = User.find_or_create_by_login(login)
    u.password = options[:password]
    u.password_confirmation = options[:password]
    u.admin = true
    u.person_id = options[:person_id] if options[:person_id]
    u.save!
    u.assign_role(:user_manager)
  end
  student_users.each do |login, options|
    u = User.find_or_create_by_login(login)
    u.password = options[:password]
    u.password_confirmation = options[:password]
    u.person = Student.find_by_student_no(options[:student_no])
    u.save!
  end
  puts "Done"
end