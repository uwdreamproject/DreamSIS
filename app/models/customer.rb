=begin
  A Customer is a business user of DreamSIS. Typically this represents a single program or organization but a single organization could potentially have multiple Customer records. This object contains all of the preferences for the Customer, such as custom labels and risk form content.

The main purpose of the Customer model is to sandbox multiple organizations' data within the same DreamSIS instance. The current Customer is stored in the current thread so that customer details are accessible system-wide for each request. For convenience, all of the Customer instance methods are available through class methods on Customer. For example, +Customer.mentor_label+ is equivalent to +Customer.find(Thread.current['customer_id']).mentor_label+.
=end
class Customer < ActiveRecord::Base
  validates_presence_of :name  
  validates_presence_of :clearinghouse_customer_number, :clearinghouse_contract_start_date, :clearinghouse_number_of_submissions_allowed, :if => :validate_clearinghouse_configuration?
  validates_numericality_of :clearinghouse_customer_number, :if => :validate_clearinghouse_configuration?
  
  belongs_to :parent_customer, :class_name => "Customer"
  belongs_to :program

  DEFAULT_LABEL = {
    :mentor => "mentor",
    :lead => "lead",
    :participant => "participant",
    :workbook => "workbook",
    :intake_survey => "intake survey",
    :mentee => "mentee"
  }

  has_many :clearinghouse_requests

  attr_accessor :validate_clearinghouse_configuration
  
  def validate_clearinghouse_configuration?
    validate_clearinghouse_configuration
  end
  
  def current_contract_clearinghouse_requests
    clearinghouse_requests.find(:all, :conditions => ["submitted_at > ?", clearinghouse_contract_start_date])
  end
  
  
  # Returns true if +term_system+ is +Quarters+.
  def use_quarters?
    term_system == "Quarters"
  end
  
  class << self

    # For now, just default to the first record in the Customer collection.
    def current_customer
      Customer.first || Customer.new(:name => "Dream Project")
    end
    
    # Returns the current customer's name
    def name_label
      current_customer.try(:name)
    end
    
    # Automatically handle +Customer.method+ by passing it on to Customer.current_customer.
    def method_missing(method_name, *args)
      if m = method_name.to_s.match(/\A(\w+)_(label|Label)\Z/)
        current_customer.customer_label(m[1], :titleize => m[2] == "Label")
      elsif current_customer.respond_to?(method_name)
        current_customer.try(method_name.to_s, *args)
      end
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
