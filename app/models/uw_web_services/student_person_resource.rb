class StudentPersonResource < UwWebResource
  self.prefix = "/student/v4/"
  self.element_name = "person"
  self.collection_name = "person"
  self.primary_key = "UWRegID"
  self.caller_class = "StudentPersonResource"
  
  def self.find(*args)
    sws_log args.inspect, "Find"
    super
  end
  
  # def self.find_by_uwnetid(uwnetid)
  #   results = self.find(nil, :params => {:uwnetid => uwnetid})
  #   return nil if results.Persons.nil?
  #   self.find results.Persons.Person.PersonURI.UWRegID
  # end
  
  def photo
    @photo ||= StudentPhoto.new(id)
  end

  # Returns a hash of course meetings for the specified Quarter in the same format as CourseResource#meetings.
  def course_meetings(quarter)
    @course_meetings ||= {}
    return @course_meetings[quarter] if @course_meetings[quarter]
    cm = {}
    for meetings in active_registrations(quarter).collect{|reg| reg.course_resource.meetings }
      meetings.each do |day,meets|
        cm[day] ||= []
        cm[day] << meets
        cm[day].flatten!
      end
    end
    @course_meetings[quarter] = cm
  end

  # Returns the active RegistrationResource objects for this student for the specified Quarter.
  def active_registrations(quarter)
    params = { :reg_id => self.RegID, :is_active => "on" }
    params[:year] = quarter.year if quarter
    params[:quarter] = quarter.quarter_title if quarter
    registrations = RegistrationResource.find(:all, :params => params)
  end
  
end