class Report < ActiveRecord::Base
  
	class AlreadyGeneratingError < StandardError
	end

	VALIDITY_PERIOD = 1.day

	validates_presence_of :key, :format, :model_name
	validates_uniqueness_of :key, scope: [ :customer_id, :format, :type ]
	serialize :object_ids

  mount_uploader :file, ReportUploader, mount_on: :file_path
  
	# Finds the most recent Report object that corresponds to this cache_key.
	# Returns nil if one doesn't exist.
	def self.for_key(cache_key)
    report = where(key: cache_key).order("updated_at DESC").first
		report.update_attribute(:status, "expired") if report && report.expired?
		report
	end
	
	def objects
		object_class.find object_ids
	end
	
	def object_class
		model_name.to_s.constantize
	end
	
	def path
		FileUtils.mkdir_p(container_path)
		File.join(container_path, filename)
	end
		
	def container_path
		File.join(Rails.root, "tmp", "reports", "tenant-#{Apartment::Tenant.current}", self.id.to_s)
	end
	
	def filename
		"report." + format.to_s
	end
	
	def expired?
		generated_at && generated_at < VALIDITY_PERIOD.ago
	end
	
	def mime_type
		Mime::Type.lookup_by_extension(format.to_s)
	end
	
	def reset_to_ungenerated
		self.status = nil if status == 'generated'
		self.generated_at = nil
		File.unlink file_path if File.exist?(file_path.to_s)
		self.save
	end
	
	# Generate the file ready for sending to the user and change status to "generated".
	def generate!
		raise AlreadyGeneratingError, "The report is already being generated." if status == 'generating'
    ActiveRecord::Base.connection_pool.with_connection do
  		reset_to_ungenerated
      begin
  			update_attribute :status, "generating"
  			temp_file = Tempfile.new("report_#{id.to_s}_#{Time.now.to_i}")
  			xlsx_package.serialize temp_file.path
  		rescue => e
  			update_attributes status: "error: #{e.message}", generated_at: nil
  			logger.warn { "ERROR generating file: #{e.message}" }
        Rollbar.warning(e, report_id: self.id)
  		else # no errors
        self.file = temp_file
        self.status = "generated"
        self.generated_at = Time.now
        self.save
  			logger.info { "Output file at: #{file.path}" }
      ensure
        temp_file.close if temp_file
      end
    end
	end
	
	def xlsx_package
	  object_class.to_xlsx(data: objects)
	end

	def generated?
		!generated_at.blank? && !file_path.blank? && status == 'generated'
	end
	
	def generating?
		status == 'generating' || status == 'initializing'
	end
	
	def error?
		status.starts_with? 'error'
	end
	
	# Kicks off a sucker_punch task to generate this report
	def generate_in_background!
    Rollbar.warning "Sidekiq not ready" unless Report.sidekiq_ready?
    ReportWorker.perform_async(self.id)
	end
  
  def self.sidekiq_ready?
    Sidekiq::ProcessSet.new.size > 0
  rescue Redis::CannotConnectError => e
    Rollbar.error(e)
    return false
  end
  
end
