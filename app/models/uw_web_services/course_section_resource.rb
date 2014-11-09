class CourseSectionResource < UwWebResource
  self.prefix = "/idcard/DreamSISProxy.php?path=student~v4~"
  self.element_name = "course"
  self.collection_name = "course"
  self.caller_class = "CourseSectionResource"
  
  def self.find(*args)
    return super(args.first.gsub(" ", "%20").gsub(/(\d{3})\/(\w)/, '\1~\2')) if args.size == 1
      # The generic proxy uses the desired resource location as a 
      # query paramater, however we now need to find a resource
      # using query paramaters so we use a different script.
      # We also use htaccess to reformat the query in /idcard
      self.prefix = "/idcard/dsproxy/CourseWithParams/"
      sws_log args.inspect, "Find"
    super
  end

  # Course ID in the format that SWS uses. For example: "2011,spring,EDUC,360/A"
  def course_id
    [[self.Year, self.Quarter, self.CurriculumAbbreviation, self.CourseNumber].join(","), self.SectionID].join("/")
  end

  # Alias for #course_id.
  def id
    course_id
  end

  # Returns the CourseResource object for instantiated CourseSectionResource objects.
  def course_resource
    @course_resource ||= CourseResource.find course_id
  end

  def self.instantiate_collection(collection, prefix_options = {})
    if collection.try(:[], "Sections").try(:[], "Section").is_a?(Array)
      collection.try(:[], "Sections").try(:[], "Section").collect!{|record| instantiate_record(record, prefix_options) }
    else
      [instantiate_record(collection.try(:[], "Sections").try(:[], "Section"), prefix_options)]
    end
  end

end
