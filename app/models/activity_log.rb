# An ActivityLog is used by a mentor to track his or her activity over the course of a week.
class ActivityLog < CustomerScoped
  belongs_to :mentor
  
	validates_presence_of :mentor_id, :start_date, :end_date
	validates_uniqueness_of :start_date, :scope => [ :mentor_id, :end_date ]
  
  default_scope :order => "start_date DESC", :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }
	
	serialize :student_time
	serialize :non_student_time
  
	# Finds or creates a new ActivityLog for the mentor based on the year
	# and week number provided (based on Monday-start weeks).
	def self.find_or_create_by_mentor_and_week_and_year(mentor, week_number, year)
		mentor_id = mentor.is_a?(Mentor) ? mentor.try(:id) : mentor
		start_date = Date.commercial(year, week_number, 1)
		end_date = Date.commercial(year, week_number, 7)
		ActivityLog.find_or_create_by_mentor_id_and_start_date_and_end_date(mentor_id, start_date, end_date)
	end
	
	# Finds or creates the ActivityLog for the mentor for the current week.
	def self.current_for(mentor)
		week_number = Date.today.cweek
		ActivityLog.find_or_create_by_mentor_and_week_and_year(mentor, week_number, Date.today.year)
	end
  
	# Returns true if this activity log "belongs to" the user or person passed as a parameter.
	# If a User is passed, this method calls +person_id+ to compare against +mentor_id+.
	def belongs_to?(user_or_person)
		return user_or_person.person_id == mentor_id if user_or_person.is_a?(User)
		return user_or_person.id == mentor_id if user_or_person.is_a?(Person)
		false
	end
	
	# Returns the week_number for this ActivityLog by returning +cweek+
	# for this ActivityLog's start_date.
	def week_number
		start_date.cweek
	end
	
	# Finds or creates an ActivityLog for the mentor for next week.
	def next_week_log
		next_week_start = (start_date + 1.week).beginning_of_week
		week_number = next_week_start.cweek
		ActivityLog.find_or_create_by_mentor_and_week_and_year(mentor_id, week_number, next_week_start.year)
	end

	# Finds or creates an ActivityLog for the mentor for last week.
	def previous_week_log
		previous_week_start = (start_date - 1.week - 1.day).beginning_of_week
		week_number = previous_week_start.cweek
		ActivityLog.find_or_create_by_mentor_and_week_and_year(mentor_id, week_number, previous_week_start.year)
	end
	
	# Returns true if the start date for this activity log is in the current week.
	def this_week?
		start_date.beginning_of_week == Date.today.beginning_of_week
	end
	
end
