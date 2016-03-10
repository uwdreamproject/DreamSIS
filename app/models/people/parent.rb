# Models a parent, legal guardian, or other adult advocate of a student in the system. This model is linked to a student through +child_id+. Note that because "child" is a reserved word, the association is called "child_person" in this model.
class Parent < Person
  include ActionView::Helpers::NumberHelper
	acts_as_xlsx

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

  belongs_to :child_person, :class_name => "Person", :foreign_key => :child_id, :touch => true
	belongs_to :highest_education_level, :class_name => "EducationLevel"

  validates_presence_of :lastname, :firstname, :parent_type

  after_save :update_filter_cache
  after_destroy :update_filter_cache

  # Updates the participant filter cache
  def update_filter_cache
    child_person.save
  end
  
  def child_firstname
    child_person.try(:firstname)
  end
  
  def child_lastname
    child_person.try(:lastname)
  end
  
	def highest_education_level_title
		highest_education_level.try(:title)
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
  
	# Determines the columns that are exported into xlsx pacakages.
	def self.xlsx_columns
    columns = [
      :id, :child_id, :child_lastname, :child_firstname, :formal_firstname, :middlename, :lastname, :suffix, 
      :parent_type, :lives_with,
      :street, :city, :state, :zip, :email, :phone_home, :phone_mobile, :phone_work,
      :other_languages, :occupation,	:annual_income,	:highest_education_level_title, :education_country,
      :meeting_availability, :needs_interpreter
    ]
	end
  
end