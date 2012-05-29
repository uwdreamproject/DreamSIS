class CourseResource < UwWebResource
  self.prefix = "/student/v4/"
  self.element_name = "course"
  self.collection_name = "course"
  self.caller_class = "CourseResource"
  
  def self.find(*args)
    return super(args.first.gsub(" ", "%20")) if args.size == 1
    sws_log args.inspect, "Find"
    super
  end
  
  # Course ID in the format that SWS uses. For example: "2011,spring,EDUC,360"
  def id
    [self.Course.Year, self.Course.Quarter, self.Course.CurriculumAbbreviation, self.Course.CourseNumber].join(",")
  end
  
  def abbreviation
    [self.Course.CurriculumAbbreviation, self.Course.CourseNumber, self.SectionID].join(" ")
  end
  
  # Shortcut method to get to the "LinkedSections" attribute in the xml payload from SWS.
  def linked_sections
    return [] if attributes["LinkedSectionTypes"].nil?
    self.LinkedSectionTypes.SectionType.LinkedSections.LinkedSection
  end
  
  # Provides an array of section ID's for all linked sections in the format ready for a call to SWS:
  # for example, "2011,spring,EDUC,360/AD"
  def linked_section_ids
    linked_sections.collect{|ls|
      [ls.Section.Year, ls.Section.Quarter, ls.Section.CurriculumAbbreviation, ls.Section.CourseNumber].join(",") +
      "/" + ls.Section.SectionID
    }
  end
  
  def active_registrations
    @active_registrations ||= RegistrationResource.find(:all, :params => {
      :curriculum_abbreviation => self.Course.CurriculumAbbreviation, 
      :year => self.Course.Year, 
      :quarter => self.Course.Quarter, 
      :course_number => self.Course.CourseNumber, 
      :section_id => self.SectionID,
      :is_active => "on"
    })
  end
  
  # Returns a hash of the meeting times for this course. At this point, this method only returns the time information;
  # it does not return anything about location. It also does not include TBA sections. The hash is formatted as such:
  # 
  # * key: day of the week (e.g., "Monday")
  # * value: an array of hashes for each meeting that day, with:
  #   * :start_time
  #   * :end_time
  #   * this CourseResource object
  def meetings
    @meetings = {}
    for meeting in meetings_array
      start_time = meeting.StartTime
      end_time = meeting.EndTime
      days = [meeting.DaysOfWeek.Days].flatten
      for day in days
        next unless day && day.attributes["Day"]
        ds = [day.attributes["Day"]].flatten
        for d in ds
          @meetings[d.attributes["Name"]] ||= []
          @meetings[d.attributes["Name"]] << {
            :start_time => start_time,
            :end_time => end_time,
            :course => self
          }
        end
      end
    end
    @meetings
  end
  
  def meetings_array
    [attributes["Meetings"].attributes["Meeting"]].flatten
  end
    
end