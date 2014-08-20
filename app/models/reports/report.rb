class Report < ActiveRecord::Base
	class AlreadyGeneratingError < StandardError
	end

	VALIDITY_PERIOD = 1.day

	validates_presence_of :key, :format, :model_name
	validates_uniqueness_of :key, :scope => [ :customer_id, :format ]
	serialize :object_ids

  mount_uploader :file, ReportUploader, :mount_on => :file_path
  
	# Finds the most recent Report object that corresponds to this cache_key.
	# Returns nil if one doesn't exist.
	def self.for_key(cache_key)
		report = find(:first, :conditions => { :key => cache_key }, :order => "updated_at DESC")
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
		File.join(Rails.root, "tmp", "reports", self.id.to_s)
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
		reset_to_ungenerated
    begin
			update_attribute :status, "generating"
	    xlsx_package = object_class.to_xlsx(:data => objects)
			temp_file = Tempfile.new("report_#{id.to_s}_#{Time.now.to_i}")
			xlsx_package.serialize temp_file.path
		rescue => e
			update_attributes :status => "error: #{e.message}", :generated_at => nil
			logger.warn { "ERROR generating file: #{e.message}" }
		else # no errors
      self.file = temp_file
      self.status = "generated"
      self.generated_at = Time.now
      self.save
      # update_attributes :file_path => file.path, :status => "generated", :generated_at => Time.now
			logger.info { "Output file at: #{file.path}" }
    ensure
      temp_file.close if temp_file
    end
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
	
	# Kicks off a rake task to generate this report
	def generate_in_background!
		logger.info { "Generating report ID #{id} via background rake process" }
		task = "reports:generate"
	  options = { :Rails.env => Rails.env, :id => id }
	  args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
		cmd = "bundle exec rake #{task} #{args.join(' ')} --trace 2>&1 &"
	  system cmd
		cmd
	end
	
end
