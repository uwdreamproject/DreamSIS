class PersonFafsa < ActiveRecord::Base
  self.table_name = "people_fafsas"
  belongs_to :person
  validates_presence_of :person_id, :year
  validates_uniqueness_of :year, :scope => :person_id
  
  attr_accessor :override_fafsa_date, :override_wasfa_date
  
  # Returns true if there is a value in the +fafsa_submitted_at+ field.
  def submitted_fafsa?
    !fafsa_submitted_at.nil?
  end
  alias_method :submitted?, :submitted_fafsa?
  
  def submitted_fafsa=(fafsa_boolean)
    if fafsa_boolean == true || fafsa_boolean == "true"
      write_attribute(:fafsa_submitted_at, override_fafsa_date || Time.now)
    else
      write_attribute(:fafsa_submitted_at, nil)
    end
  end
  
  # Returns true if there is a value in the +wasfa_submitted_at+ field.
  def submitted_wasfa?
    !wasfa_submitted_at.nil?
  end
  
  def submitted_wasfa=(wasfa_boolean)
    if wasfa_boolean == true || wasfa_boolean == "true"
      write_attribute(:wasfa_submitted_at, override_wasfa_date || Time.now)
    else
      write_attribute(:wasfa_submitted_at, nil)
    end
  end
  
end