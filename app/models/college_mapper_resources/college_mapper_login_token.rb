class CollegeMapperLoginToken < CollegeMapperResource
  self.prefix = "/api/v1/counselors/:counselor_id/"
  self.element_name = "login_token"
  self.collection_name = "login_token"
  self.caller_class = "CollegeMapperLoginToken"
  
  def expires_at
    Time.parse attributes["expires_at"]
  end
  
  def expired?
    expires_at.past?
  end

  # Returns a fully usable URL to redirect a DreamSIS user to. Include a
  # CollegeMapper student ID if you want to redirect to that student's profile
  # after login.
  def login_url(student_id = nil)
    url = URI self.class.site.to_s.gsub(/(\w[^:]+):(\w[^@]+)@/, "") # strip out any basic auth credentials
    url.path = "/api/v1/vicarious_login"
    url.query = "redirect_to=/counselors/timeline/#{student_id}" if student_id
    url.to_s
  end
  
end