class CourseSectionResource < UwWebResource
  self.prefix = "/student/v5/"
  self.element_name = "section"
  self.collection_name = "section"
  self.caller_class = "CourseSectionResource"
  
  def self.find(*args)
    return super(args.first.gsub(" ", "%20")) if args.size == 1
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
