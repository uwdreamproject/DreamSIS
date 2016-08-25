=begin
  A Customer is a business user of DreamSIS. Typically this represents a single program or organization but a single organization could potentially have multiple Customer records. This object contains all of the preferences for the Customer, such as custom labels and risk form content.

The main purpose of the Customer model is to sandbox multiple organizations' data within the same DreamSIS instance. The current Customer is stored in the current thread so that customer details are accessible system-wide for each request. For convenience, all of the Customer instance methods are available through class methods on Customer. For example, +Customer.mentor_label+ is equivalent to +Customer.find(Thread.current['customer_id']).mentor_label+.
=end
class Customer < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :clearinghouse_customer_number, :clearinghouse_contract_start_date, :clearinghouse_number_of_submissions_allowed, if: :validate_clearinghouse_configuration?
  validates_numericality_of :clearinghouse_customer_number, if: :validate_clearinghouse_configuration?
  validates_format_of :stylesheet_url, with: URI::regexp(%w(http https)), allow_blank: true
  
  belongs_to :parent_customer, class_name: "Customer"
  belongs_to :program

  delegate :website_url, to: :program

  DEFAULT_LABEL = {
    mentor: "mentor",
    lead: "lead",
    participant: "participant",
    workbook: "workbook",
    intake_survey: "intake survey",
    mentee: "mentee",
		not_target: "not target",
    visit: "visit"
  }
  
  RESERVED_SUBDOMAINS = %w[www public assets admin identity development production staging dreamsis]
  validates_presence_of :url_shortcut
  validates_uniqueness_of :url_shortcut
  validates_exclusion_of :url_shortcut, in: RESERVED_SUBDOMAINS, message: "URL shortcut %s is not allowed"

  OMNIAUTH_PROVIDERS = %w[facebook twitter google_oauth2 shibboleth windowslive linkedin identity]

  # validate :tenant_database_must_exist
  after_create :create_tenant!
  after_save :reset_customer_in_thread

  has_many :clearinghouse_requests
  
  serialize :allowable_login_methods
  
  acts_as_taggable_on :mentor_term_tags
  acts_as_ordered_taggable_on :visit_attendance_options

  attr_accessor :validate_clearinghouse_configuration
  
  def validate_clearinghouse_configuration?
    validate_clearinghouse_configuration
  end
  
  def current_contract_clearinghouse_requests
    clearinghouse_requests.where(["submitted_at > ?", clearinghouse_contract_start_date])
  end
  
  def uses_clearinghouse?
    !clearinghouse_customer_number.blank?
  end
  
  # Returns the NSC customer number as a string with left-padded zeros, per NSC practice.
  # To return the stored integer version, pass +false+ for the +return_integer+ parameter.
  def clearinghouse_customer_number(return_integer = false)
    raw = read_attribute(:clearinghouse_customer_number)
    return nil if raw.nil?
    return_integer ? raw : raw.to_s.rjust(6, "0")
  end
  
  # If the Customer defines a different name for use with ClearinghouseRequests, return that.
  # Otherwise, just return the name.
  def name_for_clearinghouse
    clearinghouse_customer_name || name
  end
  
  # Returns true if +term_system+ is +Quarters+.
  def use_quarters?
    term_system == "Quarters"
  end
  
  def require_risk_form?
    !risk_form_content.blank?
  end

  def require_conduct_form?
    !conduct_form_content.blank?
  end

  def require_driver_form?
    !driver_form_content.blank?
  end

  # returns human readable string of the validity length of driver training
  def helper_driver_training_validity_length
    helper_validity_length(driver_training_validity_length)
  end

  # returns human readable string of the validity length of background checks
  def helper_background_check_validity_length
    helper_validity_length(background_check_validity_length)
  end

  # If there exists an event type with the +name+ "Mentor Workshop", returns it, otherwise nil
  def mentor_workshop_event_type
    EventType.find_by_name("Mentor Workshop")
  end

  def allowable_login_method?(provider)
    allowable_login_methods_list.include? provider.to_s
  end
  
  def allowable_login_methods_list
    list_from_db = allowable_login_methods.try{|h| h.select{ |k,v| v == "true" }.keys } || [] rescue []
    list_from_db & OMNIAUTH_PROVIDERS # only allow providers listed to be included
  end
  
  # Parses the text in +college_application_choice_options+ and returns an array that is split on newlines.
  def college_application_choice_options_array
    return %w[Reach Solid Safety] if college_application_choice_options.blank?
    college_application_choice_options.try(:split, "\n").try(:collect, &:strip).to_a
  end

  # Parses the text in +paperwork_status_options+ and returns an array that is split on newlines.
  def paperwork_status_options_array
    return ["Not Started", "In Progress", "Complete"] if paperwork_status_options.blank?
    paperwork_status_options.try(:split, "\n").try(:collect, &:strip).to_a
  end

  # Parses the text in +activity_log_student_time_categories+ and returns an array that is split on newlines.
  def activity_log_student_time_categories_array
    activity_log_student_time_categories.try(:split, "\n").try(:collect, &:strip).to_a
  end

  # Parses the text in +activity_log_non_student_time_categories+ and returns an array that is split on newlines.
  def activity_log_non_student_time_categories_array
    activity_log_non_student_time_categories.try(:split, "\n").try(:collect, &:strip).to_a
  end
	
	# Returns true if there is anything in the acitivity log categories fields.
	def uses_activity_logs?
		!activity_log_student_time_categories.blank? || !activity_log_non_student_time_categories.blank?
	end
	
	# Returns true if there is anything in the visit attendance options field.
	def uses_visit_attendance_options?
		!visit_attendance_options.blank?
	end
	
	# Parses the text in +visit_attendance_options+ and returns an array that is split on newlines.
	# Visit attendance always includes "Attended" as an option, but this allows customers to provide
	# other options that might also count when reporting attendance.
	def visit_attendance_options_array
		(visit_attendance_option_list + ["Attended"]).uniq
	end
  
  # Returns the current customer record by looking up the Customer whose url_shortcut matches the tenant name.
  def self.current_customer(reset = false)
    return Thread.current['customer'] if Thread.current['customer'] && !reset
    @current_customer ||= {}
    @current_customer[Apartment::Tenant.current] ||= Customer.where(url_shortcut: Apartment::Tenant.current).first || Customer.new
  end
  
  # Unset the customer attribute in the current thread. Used as an +after_save+ callback to pick up changes.
  def reset_customer_in_thread
    Thread.current['customer'] = nil
  end
  
  # The tenant name used by this Customer for apartment multitenancy.
  def tenant_name
    url_shortcut
  end
  
  # Shortcut for +Apartment::Tenant.switch(:tenant)+.
  def self.switch(tenant_name)
    Apartment::Tenant.switch(tenant_name)
  end
  
  # Create a new tenant database.
  def create_tenant!
    Apartment::Tenant.create(tenant_name) unless tenant_name.blank?
    initialize_tenant!
  end
  
  # Loads the schema and seeds the Customer's tenant record to the latest migration.
  def initialize_tenant!
    @database_schema_file = Rails.root.join('db', 'schema.rb')
    @database_seeds_file = Rails.root.join('db', 'seeds.rb')
    
    Customer.transaction do
      Apartment::Tenant.switch(tenant_name) do
        load(@database_schema_file)
        load(@database_seeds_file) if Apartment.seed_after_create
      end
    end
    
    return true
  end
  
  # Returns true if the tenant database exists, which must be done before creating a new Customer.
  # def tenant_database_must_exist
  #   begin
  #     Apartment::Tenant.switch(tenant_name) do
  #       true
  #     end
  #   rescue Apartment::TenantNotFound => e
  #     errors.add :base, "Tenant database must exist before Customer record is created."
  #   end
  # end
  
  # Creates a Redis namespace for this customer to use.
  def redis
     @redis ||= Redis::Namespace.new(url_shortcut, redis: $redis)
  end

  # Returns the current customer's name
  def self.name_label
    current_customer.try(:name)
  end
  
  # Automatically handle +Customer.method+ by passing it on to Customer.current_customer.
  def self.method_missing(method_name, *args)
    current_customer.method_missing(method_name, *args)
  end
  
  # Automatically handle the same method_missing for individual Customer objects.
  def method_missing(method_name, *args)
    if m = method_name.to_s.match(/\A(\w+)_(label|Label)\Z/)
      customer_label(m[1], titleize: m[2] == "Label")
    elsif respond_to?(method_name)
      try(method_name.to_s, *args)
    else
      super(method_name, *args)
    end
  end
  
  # Returns the specified label for this customer, or the default label if the customer does not specify.
  # Pluralizing the label_name will automatically pluralize the output (e.g., "mentors_label") and
  # capitalizing the "L" in "label" will automatically titleize the output (e.g., "mentors_Label").
  def customer_label(label_name, options = {})
    if plural_match = label_name.to_s.match(/(\w+)s\Z/)
      pluralize = true
      label_name = plural_match[1]
    end
    method_name = "#{label_name.to_s}_label"
    return_label = self.try(method_name) if self.respond_to?(method_name)
    return_label = DEFAULT_LABEL[label_name.to_sym] if return_label.blank?
    format_customer_label(return_label, titleize: options[:titleize], pluralize: pluralize)
  end

  def format_customer_label(return_label, options = {})
    options.merge({titleize: false, pluralize: false})
    return_label = return_label.pluralize if options[:pluralize]
    return_label = return_label.titleize if options[:titleize]
    return return_label
  end
	
	# Tries to guess the appropriate "opposite" title for the not_target label.
	def not_target_opposite_label
		case read_attribute(:not_target_label)
		when "unofficial"
			"official"
		when "not target"
			"target"
		when ""
			"target"
		when nil
			"target"
		else
			"not " + not_target_label
		end
	end

  private

  # helper method to calculate and return the validity length as a string
  def helper_validity_length(length)
    if length.nil?
      return "(Length not set)"
    end
    str = "(valid for: "
    if (length == 0)
      str += "0 days"
    elsif (length == -1)
      str += "Forever"
    else
      years = length / 365;
      days = length % 365;
      if years > 0
      str += "#{years} " + 'year'.pluralize(years)
      end
      if days > 0
        if years > 0
          str += " and "
	    end
	    str +=  "#{days} days"
      end
    end
    return str + ")"
  end

end
