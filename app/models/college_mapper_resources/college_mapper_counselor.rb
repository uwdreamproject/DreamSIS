class CollegeMapperCounselor < CollegeMapperResource
  self.prefix = "/api/v1/"
  self.element_name = "counselors"
  self.collection_name = "counselors"
  self.caller_class = "CollegeMapperCounselor"
  
  def login_token(force = false)
    return @login_token if @login_token && !@login_token.expired? && !force
    @login_token = CollegeMapperLoginToken.find(nil, :params => {:counselor_id => self.id})
  end
  
  def associations(scope = :all)
    @associations ||= CollegeMapperAssociation.find(scope, :params => {:account_type => "counselors", :user_id => self.id})
  end
  
end