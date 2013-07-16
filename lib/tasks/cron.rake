namespace :cron do
  
  namespace :mentor_term_groups do

    desc "Sync course enrollees for current term mentor groups"
    task :sync_course_enrollees => :environment do
      STDOUT.sync = true
      puts "Syncing course enrollees for current term mentor groups..."
      Term.allowing_signups.each do |q|
        puts "  #{q.title}"
        q.mentor_term_groups.each do |group|
          next if group.course_id.blank?
          print "    #{group.course_id}: "
          print "sync_with_course => #{group.sync_with_course!}, "
          puts "update_resource_cache => #{!group.mentors.collect{|m| m.update_resource_cache!(true)}.include?(false)}"
        end
      end
      puts "done."
    end
    
    desc "Update group resource for current term mentors"
    task :update_group_membership => :environment do
      STDOUT.sync = true
      puts "Updating group membership for current term mentors..."
      Term.allowing_signups.each do |q|
        q.update_group_membership!
        puts "  #{q.title}"
      end 
      puts "done."
    end

  end
  
end
        
        