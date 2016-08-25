namespace :test do
  
  namespace :tenant do

    desc "Setup a dummy tenant that can be used for invoking tests against."
    task :prepare => :environment do
      puts "Setting up tenant 'test-customer'\n"
      Customer.create!(name: 'Test Customer', url_shortcut: 'test-customer')
      Apartment::Tenant.switch! 'test-customer'
      at_exit { Rake::Task["test:tenant:drop"].invoke }
    end
    
    desc "Drop the dummy tentant used for testing."
    task :drop => :environment do
      puts "Dropping tenant 'test-customer'\n"
      Customer.where(url_shortcut: 'test-customer').delete_all
      Apartment::Tenant.drop('test-customer') rescue nil
    end

  end
    
end

# Ensure that these tasks run before and after our default `rake test` tasks.
Rake::Task["test"].enhance ["test:tenant:drop", "test:tenant:prepare"]
