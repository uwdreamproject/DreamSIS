namespace :reports do

	desc "Generate a report in the background"
	task :generate => :environment do
		begin
		  Apartment::Tenant.switch(ENV['TENANT'])
			@report = Report.find ENV['ID']
			Rails.logger.info { "[reports:generate] Found report ##{@report.id}, starting generate!"}
			@report.generate!
			Rails.logger.info { "[reports:generate] Done."}
		rescue => e
			Rails.logger.error { "[reports:generate] *** ERROR: #{e.message}" }
		end
	end
	
end
