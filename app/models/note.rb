# Any object within DreamSIS can be notated with a Note. Note accepts a polymorphic association called +notable+ that can be used to add notes to another model. Notes can also have arbitrary documents attached to them, which are stored on S3 using CarrierWave. If you want to validate that a Note has a valid document, use the +validate_document+ method (say, if you have a form that you want to collect a document with).
class Note < ActiveRecord::Base
  belongs_to :notable, polymorphic: true, touch: true
  belongs_to :user, class_name: "User", foreign_key: "creator_id"
  validates_presence_of :notable_type, :notable_id
	validates_presence_of :note, unless: :validate_document?
	validates_presence_of :document, :title, if: :validate_document?

  before_create :update_creator_id
  default_scope { order("created_at DESC") }

  after_save :update_parent_counter_cache
  
  mount_uploader :document, DocumentUploader, mount_on: :document_file_name
	
  attr_accessor :validate_document
  def validate_document?
    validate_document
  end
	
  def update_parent_counter_cache
    if notable.respond_to?(:followup_note_count)
      notable.update_attribute :followup_note_count, notable.notes.where(needs_followup: true).count
    end
  end
  
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
