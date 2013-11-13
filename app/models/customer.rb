=begin
  A Customer is a business user of DreamSIS. Typically this represents a single program or organization but a single organization could potentially have multiple Customer records. This object contains all of the preferences for the Customer, such as custom labels and risk form content.

The main purpose of the Customer model is to sandbox multiple organizations' data within the same DreamSIS instance. The current Customer is stored in the current thread so that customer details are accessible system-wide for each request. For convenience, all of the Customer instance methods are available through class methods on Customer. For example, +Customer.mentor_label+ is equivalent to +Customer.find(Thread.current['customer_id']).mentor_label+.
=end
class Customer < ActiveRecord::Base
  validates_presence_of :name  
  validates_presence_of :clearinghouse_customer_number, :clearinghouse_contract_start_date, :clearinghouse_number_of_submissions_allowed, :if => :validate_clearinghouse_configuration?
  validates_numericality_of :clearinghouse_customer_number, :if => :validate_clearinghouse_configuration?
  validates_uniqueness_of :url_shortcut, :allow_blank => true
  
  belongs_to :parent_customer, :class_name => "Customer"
  belongs_to :program

  delegate :website_url, :to => :program

  DEFAULT_LABEL = {
    :mentor => "mentor",
    :lead => "lead",
    :participant => "participant",
    :workbook => "workbook",
    :intake_survey => "intake survey",
    :mentee => "mentee",
		:not_target => "not target"
  }

  has_many :clearinghouse_requests
  
  serialize :allowable_login_methods

  attr_accessor :validate_clearinghouse_configuration
  
  def validate_clearinghouse_configuration?
    validate_clearinghouse_configuration
  end
  
  def current_contract_clearinghouse_requests
    clearinghouse_requests.find(:all, :conditions => ["submitted_at > ?", clearinghouse_contract_start_date])
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
  
  # Returns true if +term_system+ is +Quarters+.
  def use_quarters?
    term_system == "Quarters"
  end
  
  def require_risk_form?
    !risk_form_content.blank?
  end
  
  def allowable_login_methods=(new_allowable_login_methods)
    self.write_attribute :allowable_login_methods, new_allowable_login_methods.select{|provider, result| result != "0"}.collect(&:first)
  end

  def allowable_login_method?(provider)
    # logger.info { "allowable_login_methods: " + allowable_login_methods.inspect }
    (allowable_login_methods || "").include?(provider.to_s)
  end
  
  # Parses the text in +college_application_choice_options+ and returns an array that is split on newlines.
  def college_application_choice_options_array
    return %w[Reach Solid Safety] if college_application_choice_options.blank?
    college_application_choice_options.split("\n").collect(&:strip)
  end

  # Parses the text in +paperwork_status_options+ and returns an array that is split on newlines.
  def paperwork_status_options_array
    return ["Not Started", "In Progress", "Complete"] if paperwork_status_options.blank?
    paperwork_status_options.split("\n").collect(&:strip)
  end

  # Parses the text in +activity_log_student_time_categories+ and returns an array that is split on newlines.
  def activity_log_student_time_categories_array
    activity_log_student_time_categories.split("\n").collect(&:strip)
  end

  # Parses the text in +activity_log_non_student_time_categories+ and returns an array that is split on newlines.
  def activity_log_non_student_time_categories_array
    activity_log_non_student_time_categories.split("\n").collect(&:strip)
  end
	
	# Returns true if there is anything in the acitivity log categories fields.
	def uses_activity_logs?
		!activity_log_student_time_categories.blank? || !activity_log_non_student_time_categories.blank?
	end
  
  def self.current_customer
    # logger.info { "user: " + User.current_user.try(:customer).inspect }
    # logger.info { "thread: " + Thread.current['customer'].inspect }
    # logger.info { "temp: " + @temporary_current_customer.inspect }
        
    customer = User.current_user.try(:customer) || @temporary_current_customer || Customer.first || Customer.create(:name => "New Customer")
    raise Exception.new("No customer record defined") unless customer && customer.is_a?(Customer)
    # logger.info { "---current_customer: #{customer.id}" }
    return customer
  end
    
  def self.current_customer=(customer)
    @temporary_current_customer = customer if customer.is_a?(Customer)
  end
  
  def self.remove_temporary_current_customer
    @temporary_current_customer = nil
  end
  
  # Returns the current customer's name
  def self.name_label
    current_customer.try(:name)
  end
  
  # Automatically handle +Customer.method+ by passing it on to Customer.current_customer.
  def self.method_missing(method_name, *args)
    # logger.info { "method_missing: #{method_name}" }
    # logger.info { "current_customer respond_to?: #{current_customer.respond_to?(:id)}" }
    if m = method_name.to_s.match(/\A(\w+)_(label|Label)\Z/)
      current_customer.customer_label(m[1], :titleize => m[2] == "Label")
    elsif current_customer.respond_to?(method_name)
      current_customer.try(method_name.to_s, *args)
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
    format_customer_label(return_label, :titleize => options[:titleize], :pluralize => pluralize)
  end

  def format_customer_label(return_label, options = {})
    options.merge({:titleize => false, :pluralize => false})
    return_label = return_label.pluralize if options[:pluralize]
    return_label = return_label.titleize if options[:titleize]
    return return_label
  end
  
end
