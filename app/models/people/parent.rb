# Models a parent, legal guardian, or other adult advocate of a student in the system. This model is linked to a student through +child_id+. 
class Parent < Person
  include ActionView::Helpers::NumberHelper

  RELATIONSHIP_TYPES = [
    "Mother", "Father", 
    "Step-Mother", "Step-Father", 
    "Grandmother", "Grandfather",
    "Foster Parent", 
    "Guardian", 
    "Other", 
    "Sister", "Brother",
    "Emergency Contact"
  ]
  
  validates_presence_of :lastname, :firstname
  validates_presence_of :child_id

  belongs_to :child  

  validates_presence_of :lastname, :firstname, :parent_type

  after_save :update_filter_cache
  after_destroy :update_filter_cache

  # Updates the participant filter cache
  def update_filter_cache
    child.save
  end
  
  # Returns the preferred method of contact, ready for printing on the page.
  # For example, if the preferred contact method is "Home Phone", this method
  # will return the phone number as a phone-formatted string.
  def preferred_contact_detail
    return nil if preferred_contact_method.blank?
    if preferred_contact_method == ("Home Phone")
      number_to_phone(phone_home)
    elsif preferred_contact_method == ("Mobile Phone")
      number_to_phone(phone_mobile)
    elsif preferred_contact_method.include?("Email")
      email
    end
  end
end