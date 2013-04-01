class CollegeMapperStudent < CollegeMapperResource
  self.prefix = "/api/v1/"
  self.element_name = "students"
  self.collection_name = "students"
  self.caller_class = "CollegeMapperStudent"
  
  def colleges
    @colleges ||= CollegeMapperCollege.find(:all, :params => { :user_id => id })
  end
  
end