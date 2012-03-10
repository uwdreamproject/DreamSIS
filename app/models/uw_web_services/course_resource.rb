class CourseResource < UwWebResource
  self.prefix = "/student/v4/"
  self.element_name = "course"
  self.collection_name = "course"
  # self.primary_key = "UWRegID"
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
    @active_registrations ||= RegistrationResource.find("registration", :params => {
      :curriculum_abbreviation => self.Course.CurriculumAbbreviation, 
      :year => self.Course.Year, 
      :quarter => self.Course.Quarter, 
      :course_number => self.Course.CourseNumber, 
      :section_id => self.SectionID,
      :is_active => "on"
    })
  end
    
end