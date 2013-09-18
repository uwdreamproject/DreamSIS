class RegistrationResource < UwWebResource
  self.prefix = "/student/v4/"
  self.element_name = "registration"
  self.collection_name = "registration"
  self.caller_class = "RegistrationResource"
  self.format = RegistrationResourceXMLFormatter.new
  
  def self.find(*args)
    sws_log args.inspect, "Find"
    super
  rescue NoMethodError
    return [] # we didn't get a valid collection of Registration resources.
  end

  attr_accessor :full_record
  
  # Returns true if this is the "full" version of the record.
  def full_record?
    full_record == true
  end

  # Fetches the full detail for this RegistrationResource. When doing a general search (<tt>RegistrationResource.find(:all)</tt>)
  # only some of the information is returned in the data payload.
  def full
    return self if full_record?
    return @full unless @full.nil?
    href = attributes["Href"]
    cleaned_href = href.gsub(self.class.prefix + self.class.element_name + "/", "").gsub(".xml", "")
    unless @full
      @full = RegistrationResource.find cleaned_href
      @full.full_record = true
    end
    @full
  end
  
  # Returns the CourseResource that is linked to this Registration.
  def course_resource
    section = full.attributes["Section"].try(:attributes)
    @course_resuorce ||= CourseResource.find [section["Year"], section["Quarter"], section["CurriculumAbbreviation"], section["CourseNumber"]].join(",") + "/" + section["SectionID"]
  end

end
