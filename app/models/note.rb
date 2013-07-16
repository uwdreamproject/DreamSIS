# Any object within DreamSIS can be notated with a Note. Note accepts a polymorphic association called +notable+ that can be used to add notes to another model.
# 
# A note can have different access levels (determined by the +access_level+ attribute):
# 
# * everyone (or blank) - any admin user can see the note
# * creator - only the creator of the note can see it
class Note < CustomerScoped
  belongs_to :notable, :polymorphic => true
  belongs_to :user, :class_name => "User", :foreign_key => "creator_id"
  # belongs_to :contact_type  

  validates_presence_of :note, :notable_type, :notable_id

  before_create :update_creator_id
  
  default_scope :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }
  
  def update_creator_id
    self.creator_id = Thread.current['user'].try(:id)
  end

  # Returns the fullname of the user who created this note, if available. If creator_id is nil, then returns +creator_name+ instead.
  # This attribute is used for legacy purposes -- when migrating data, we might only have a person's initials or insufficient data
  # to create a valid Person record to link the Note to, so we can at least store something and recall it.
  def fullname
    user ? user.fullname : creator_name
  end
  
  # Returns true if the user passed is allowed to view this note.
  def allows?(newuser)
    if access_level == 'creator'
      return false if newuser != user
    end
    true
  end
  
  # Returns true if +access_level+ is anything other than "everyone" or nil.
  def restricted?
    access_level != 'everyone' && !access_level.blank?
  end

  # Provides a human-readable interpretation of the access level restrictions for this note.
  # 
  # For 'creator' notes: "You are the only one who can see this note."
  def restriction_in_words
    if access_level == 'creator'
      "You are the only one who can see this note."
    # elsif access_level == 'unit'
    #   "Only #{user.units.collect(&:name).join(" and ") rescue 'your program unit'} staff can see this note."
    else
      "Any DreamSIS user can see this note."
    end
  end
  
end
