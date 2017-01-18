class Report
  
	VALIDITY_PERIOD = 5.days

  # Creates a new instance of the object, but does not persist anything to the cache.
	def initialize(params, tenant = Apartment::Tenant.current)
    @params = params
    @status = nil
    @tenant = tenant
    @uploader ||= ReportUploader.new(self)
    set 'params', @params
    set 'tenant', @tenant
    set 'type', self.class.to_s.titleize
    refresh_download_url if get('filename')
	end
  
  # Returns the sha1 hash that identifies this report.
  def id
    @id ||= Digest::SHA1.hexdigest([filter_selections.sort.to_s, self.class, @tenant.to_s].join("--"))
  end
	
  # Generates a consistent key for redis by SHA1 hashing the params used to find the records.
  def redis_key(extra = nil)
    [@tenant.to_s, "Report", self.class, id, extra].compact.join(":")
  end
  
  # Store an attribute for this report.
  def set(field, value, broadcast = true)
    $redis.hset redis_key, field, value
    ActionCable.server.broadcast "report:#{id}", attributes if broadcast
    return value
  end
  
  # Get an attribute for this report.
  def get(field)
    $redis.hget redis_key, field
  end

  # Convenience method to get the 'status' attribute.
  def status
    @status = get(:status)
  end
  
  # Returns the tenant name for this report.
  def tenant
    @tenant
  end
  
  # Return all attributes stored for this reprt.
  def attributes
    { id: id }.merge($redis.hgetall(redis_key))
  end

  # Returns an ActiveRecord::Relation of all the objects that should be included in the report.
  def objects
    @objects ||= Participant.where(id: object_ids)
  end
  
  def refresh_download_url
    return nil unless get('filename')
    @uploader.retrieve_from_store! get('filename')
    set 'download_url', @uploader.url
  end
  
  # Instruct redis to expire this report in a certain number of seconds.
  def expire_in(seconds)
    $redis.expire redis_key, seconds
  end
  
  # Parse the params that were provided to construct a hash for finding the relevant records.
  def filter_selections
    Rack::Utils.parse_query(@params)
  end
  
  # Returns the objects that match the intersection of the filter selections for this report.
	def object_ids
		query = []
    for key, value in filter_selections
      if value.blank?
        next
      elsif value.is_a?(Array)
        query << value.collect{ |v| [key, v].join(":") }
      else
        query << [key, value].join(":")
      end
    end
    @object_ids = Participant.intersect(query.flatten.compact)
	end
  
  # The column headers to put at the top of the exported file. Override this in child classes.
  def column_headers
    Participant.attribute_names.collect(&:titleize)
  end
  
  # Given an object, construct an xlsx row. Override this in child classes.
  def row(object)
    object.attributes.values
  end

  def xlsx_package
    @xlsx_package ||= Axlsx::Package.new
  end

  def new?
    status.nil?
  end
  
	def generated?
		status == 'generated'
	end
	
	def generating?
		status == 'generating' || status == 'initializing'
	end
	
	def error?
		status.starts_with? 'error'
	end
	
	# Kicks off a background job to generate this report
	def generate_in_background!
    ReportJob.perform_later(self.class.to_s, @params, @tenant)
	end
  
	# Generate the file ready for sending to the user and change status to "generated".
	def generate!
    set 'status', 'generating'
    compose_package
    store_package
    set 'status', 'generated'
    set 'generated_at', Time.now.iso8601
    expire_in VALIDITY_PERIOD
  rescue => e
    Rollbar.warning e
    raise if Rails.env.development?
    set 'status', "error: #{e.message}"
  end

  protected

  def compose_package
    xlsx_package.workbook.add_worksheet(:name => self.class.to_s.titleize) do |sheet|
      update_progress(0)
      sheet.add_row column_headers
      objects.each_with_index do |object, i|
        sheet.add_row row(object)
        update_progress(i+1)
      end
      set 'percent', 100
    end
    Rails.logger.info { "Completed composing Report package" }
  end
  
  def update_progress(current)
    @total ||= set('total', objects.count, false)
    set 'processed', current, false
    previous_percent = @percent
    @percent = (1.0 * current / @total * 100).round
    set 'processed', current, false
    set 'percent', @percent, (previous_percent != @percent)
  end
  
  def store_package
    file = Tempfile.new(["report", '.xlsx'])
    file.binmode
    file.write(xlsx_package.to_stream.read)
    file.close
    Rails.logger.info { "Stored Report package in tempfile: " + file.path }
    @uploader.cache_dir = File.dirname(file.path)
    @uploader.store!(File.open(file.path, 'rb'))
    set 'download_url', @uploader.url
    set 'filename', @uploader.filename
    Rails.logger.info { "Uploaded Report package as " + @uploader.filename }
  end

end
