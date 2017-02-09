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

  namespace :institutions do
    
    desc "Reload and cache IPEDS database (if needed)"
    task :load => :environment do
      Rails.logger = Logger.new(STDOUT)
      STDOUT.sync = true
      bt = Benchmark.realtime do 
        puts "Reloading IPEDS database into Institutions..."
        Institution.all; nil
        print "Done "
      end
      puts "(took #{'%.2f' % bt} seconds)."
    end
  end
  
  namespace :people do 
  
    desc "Update the filter cache for all Person records in the database"
    task :update_filter_caches => :environment do
      Rails.logger = Logger.new(STDOUT)
      STDOUT.sync = true
    
      bt = Benchmark.realtime do 
        puts "Updating filter caches for all Person records..."
        for customer in Customer.all
          print "  #{customer.name}... "
          Customer.switch(customer.tenant_name) rescue next
          i = 0
          Person.find_in_batches do |group|
            group.each do |person|
              before = person.filter_cache || {}
              new = person.update_filter_cache!
              person.update_column(:filter_cache, new.to_yaml) && i = i+1 if before.diff(new) == {}
            end
          end
          puts "updated #{i} records."
        end
        print "Done "
      end
      puts "(took #{'%.2f' % bt} seconds)."
    
    end  
  end
  
end
        
        
