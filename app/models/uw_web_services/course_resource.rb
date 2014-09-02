class CourseResource < UwWebResource
  self.prefix = "/idcard/DreamSISProxy.php?path=student~v4~"
  self.element_name = "course"
  self.collection_name = "course"
  self.caller_class = "CourseResource"
  
  def self.find(*args)
    if args && args.first.include?("/")
      # Uses /public/ to avoid  attaching certs to standard request
      uri = URI.parse(("https://expo.uaa.washington.edu/" + "idcard/dsproxy/" + "coursejson.php?course=" + args.first).sub(' ', '%20'))
      puts uri.request_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      fetch = JSON.parse(response.body)
      puts fetch
      term = fetch["Term"]
      fetch.delete("Term")
      fetch["TermA"] = term
      return CourseResource.new(fetch) 
    else
      puts args.first
      RAILS_DEFAULT_LOGGER.info(args.first + "\n\n")
      return super(args.first.gsub(" ", "%20")) if args.size == 1
      sws_log args.inspect, "Find"
      super
    end
  end
  
  # Course ID in the format that SWS uses. For example: "2011,spring,EDUC,360"
  def id(include_section_id = true)
    course = self.attributes["Course"] || self
    curriculum = course.attributes["Curriculum"] || course
    base_id = [curriculum.Year, curriculum.Quarter, curriculum.CurriculumAbbreviation, course.CourseNumber].join(",")
    base_id << "/" + self.PrimarySection.SectionID if include_section_id && self.PrimarySection.SectionID rescue nil
    return base_id
  end
  
  def abbreviation
    course = self.attributes["Course"] || self
    [
      (course.attributes["CurriculumAbbreviation"] || course.attributes["Curriculum"].attributes["CurriculumAbbreviation"]), 
      course.attributes["CourseNumber"], 
      self.attributes["SectionID"]
    ].join(" ").strip
  end
  
  # Shortcut method to get to the "LinkedSections" attribute in the xml payload from SWS. If the data payload
  # does not provide any linked sections, this method calls #associated_sections instead (bypass this by passing
  # +false+ for +return_associated_sections_on_nil+).
  def linked_sections(return_associated_sections_on_nil = true)
    return associated_sections if return_associated_sections_on_nil && attributes["LinkedSectionTypes"].nil?
    self.LinkedSectionTypes.SectionType.LinkedSections.LinkedSection
  end

  # Performs a CourseSectionResource#find on this course's base ID, which should return all associated sections for this
  # Course. This is useful for courses that do not specify any "LinkedSections" and you just need all of the sections
  # for this Course.
  def associated_sections
    course = self.attributes["Course"] || self
    curriculum = course.attributes["Curriculum"] || course
    @associated_sections ||= CourseSectionResource.find(:all, :params => {
      :year =>  curriculum.attributes["Year"],
      :quarter => curriculum.attributes["Quarter"],
      :curriculum_abbreviation => curriculum.attributes["CurriculumAbbreviation"],
      :course_number => course.CourseNumber
    }).collect(&:course_resource)
  end
  
  # Provides an array of section ID's for all linked sections in the format ready for a call to SWS:
  # for example, "2011,spring,EDUC,360/AD"
  def linked_section_ids
    linked_sections.collect do |ls|
      if ls.attributes["Section"]
        [ls.Section.Year, ls.Section.Term, ls.Section.CurriculumAbbreviation, ls.Section.CourseNumber].join(",") +
        "/" + ls.Section.SectionID
      else
        ls.id
      end
    end
  end
  
  def active_registrations
    course = self.attributes["Course"] || self
    curriculum = course.attributes["Curriculum"] || course
    @active_registrations ||= RegistrationResource.find(:all, :params => {
      :curriculum_abbreviation => curriculum.attributes["CurriculumAbbreviation"], 
      :year => curriculum.attributes["Year"], 
      :quarter => curriculum.attributes["Quarter"], 
      :course_number => course.attributes["CourseNumber"], 
      :section_id => self.attributes["SectionID"],
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
            :start_time_parsed => Time.parse(start_time),
            :end_time => end_time,
            :end_time_parsed => Time.parse(end_time),
            :course => self
          }
        end
      end
    end
    @meetings
  end
  
  def meetings_array
    [attributes["Meetings"]].flatten
  end
  
  # Returns an array of the multiple lines of the time schedule "comments" field from the student database.
  # If the Student web service doesn't return any comment lines, this method returns an empty Array.
  def time_schedule_comments
    return [] if attributes["TimeScheduleComments"].attributes["SectionComments"].attributes["Lines"].nil?
    [attributes["TimeScheduleComments"].attributes["SectionComments"].attributes["Lines"].attributes["Line"]].flatten.collect(&:Text)
  end
   
end
