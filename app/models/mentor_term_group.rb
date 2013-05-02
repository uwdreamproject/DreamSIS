class MentorTermGroup < ActiveRecord::Base
  belongs_to :term 
  belongs_to :location
  
  has_many :mentor_terms, :include => :mentor, :conditions => { :deleted_at => nil } do
    def leads
      find(:all, :conditions => { :lead => true })
    end
  end
  has_many :mentors, :through => :mentor_terms, :conditions => "mentor_terms.deleted_at IS NULL", :order => "lastname, firstname"
  has_many :deleted_mentor_terms, :class_name => "MentorTerm", :conditions => "deleted_at IS NOT NULL"

  validates_presence_of :term_id
  validates_uniqueness_of :course_id, :scope => :term_id, :allow_nil => true, :allow_blank => true
  
  belongs_to :linked_group, :class_name => "MentorTermGroup"

  after_create :sync_with_course!
  attr_accessor :skip_sync_after_create

  default_scope :order => "title IS NULL, title, course_id"

  # Returns the course ID if no title is specified.
  def title
    read_attribute(:title).blank? ? course_id : read_attribute(:title)
  end
  
  def times_pretty
    str = ""
    str << depart_time.to_s(:time12) if depart_time
    str << "&ndash;#{return_time.to_s(:time12)}" if return_time
    str
  end

  # Pulls off just the section ID from the course_id (the part after the slash), e.g., "AF"
  def section_id
    return nil if course_id.blank?
    match = course_id.match(/\/(\w+)$/)
    match ? match[1] : nil
  end

  # Returns the associated CourseResource for this group, if +course_id+ is set.
  def course_resource
    return nil if course_id.blank?
    @course_resource ||= CourseResource.find(course_id)
  end
  
  # Returns true if the mentor_term_count is greater than the capacity. Always returns false if cap is nil.
  def full?
    return false if capacity.nil?
    capacity - mentor_terms_count <= 0
  end

  # Returns a float value for how full this group is (note, this can be over 100%). 100 = completely full, 50 = half full.
  def percent_full
    return 0.0 if capacity.nil?
    return 0.0 if mentor_terms_count.nil?
    mentor_terms_count.to_f / capacity.to_f * 100
  end
  
  # Returns the length of this visit in minutes. Returns +NaN+ if +return_time+ and +depart_time+ are both nil.
  def length
    return 0.0/0.0 unless depart_time && return_time
    (return_time - depart_time)/60
  end
  
  # Returns the number of spots left in this group, or nil if no capacity is defined.
  def spots_left
    return nil if capacity.nil?
    spots_left = capacity - mentor_terms_count
    spots_left < 0 ? 0 : spots_left
  end
  
  # Given an array of other MentorTermGroup objects, this method returns an array of matching objects whose times overlap on a schedule.
  def overlaps_with(other_groups, options = {})
    return [] if other_groups.nil?
    matching_groups = []
    for other in other_groups
      match = false
      matching_groups << other if other == self && options[:include_self]
      next if other == self
      next if other.day_of_week != day_of_week
      next if other.depart_time.nil? || other.return_time.nil?
      self_range = (depart_time.to_time.to_i..return_time.to_time.to_i)  
      other_range = (other.depart_time.to_time.to_i..other.return_time.to_time.to_i)  
      match = self_range.intersection(other_range)
      matching_groups << other if match
    end
    matching_groups
  end

  # Syncs this MentorTermGroup with the UW course it is linked with (if +course_id+ is not nil).
  # Creates a MentorTerm record for each active registration in the section and removes MentorTerm
  # records for mentors who have dropped the class.
  # 
  # Returns true if the sync completed successfully or false if no sync occurred.
  def sync_with_course!
    return false if course_id.nil?
    return false if skip_sync_after_create
    begin
      course = CourseResource.find(course_id)
      active_reg_ids = course.active_registrations.collect(&:RegID) rescue []
      # Destroy the ones that shouldn't be in there anymore
      mentor_terms.each{|mq|
        next if mq.volunteer?
        reg_id = mq.mentor.reg_id
        if active_reg_ids.include?(reg_id)
          active_reg_ids.delete(reg_id)
        else
          mq.destroy
        end
      }
      # Add in the new ones
      active_reg_ids.each{|reg_id|
        mentor = Mentor.find_or_create_from_reg_id(reg_id)
        enroll!(mentor, :volunteer => false)
      }
      # Update the counter cache
      diff = mentor_terms.count - mentor_terms_count
      MentorTermGroup.update_counters self.id, :mentor_terms_count => diff
      
      return true
    rescue ActiveResource::ResourceNotFound
      return false
    end
  end
  
  # Returns all current and deleted mentor objects.
  def mentors_with_deleted
    @mentors_with_deleted ||= (mentors + deleted_mentor_terms.collect(&:mentor)).flatten.uniq
  end

  # Enrolls the mentor in this group, unless the mentor is already a member of the group. This method
  # will properly handle a mentor who has previously been deleted and is now re-enrolling, such as
  # a mentor who was a volunteer but is now enrolled for credit. The options hash accepts a +volunteer+
  # parameter which will enable the +volunteer+ flag.
  def enroll!(mentor, options = { :volunteer => false })
    enroll_as_volunteer = options[:volunteer] || false
    mentor_term = mentor_term_for_mentor(mentor)
    begin
      if mentor_term
        mentor_term.deleted_at = nil && increment(:mentor_terms_count, 1) if mentor_term.deleted?
        mentor_term.volunteer = enroll_as_volunteer
        mentor_term.save!
      else
        mentor_term = mentor_terms.initialize_by_mentor_id(mentor.id)
        mentor_term.volunteer = enroll_as_volunteer
        mentor_term.save!
      end
    end
    mentor_term
  end
  
  # Get the MentorTerm record for the requested mentor, deleted or not. Returns nil if the
  # mentor doesn't have any MentorTerm records for this group.
  def mentor_term_for_mentor(mentor)
    mentor_term = mentor_terms.find_by_mentor_id(mentor.id) rescue nil
    mentor_term ||= deleted_mentor_terms.find_by_mentor_id(mentor.id) rescue nil
    return mentor_term
  end
  
  # Creates MentorTermGroups for all of the specified term's course linked sections if they
  # don't already exist for that term.
  def self.create_from_linked_sections!(term_id)
    return false if term_id.nil?
    term = Term.find(term_id)
    return false if term_id.nil?
    section_ids = term.courses.collect(&:linked_section_ids).flatten rescue []
    return true if section_ids.empty?
    already_done = term.mentor_term_groups.collect(&:course_id).flatten
    for section_id in section_ids
      next if already_done.include?(section_id)
      term.mentor_term_groups.create(:course_id => section_id, :skip_sync_after_create => true)
    end
    return true
  end
  
end
