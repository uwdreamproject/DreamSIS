class CollegeMapperCollege < CollegeMapperResource
  self.prefix = "/api/v1/students/:user_id/"
  self.element_name = "colleges"
  self.collection_name = "colleges"
  self.caller_class = "CollegeMapperCollege"

  def self.delete(*args)
    sws_log args.inspect, "Delete"
    self.prefix = "/api/v1/students/#{args.last[:params][:user_id]}/" if args.last.is_a?(Hash)
    self.post(args.first, {_method: "DELETE"})
  end
  
  def id
    collegeId
  end

  def removed?
    removed == "1" ? true : false
  end
  
end
