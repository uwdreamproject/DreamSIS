class CollegeMapperAssociation < CollegeMapperResource
  self.prefix = "/api/v1/:account_type/:user_id/"
  self.element_name = "associations"
  self.collection_name = "associations"
  self.caller_class = "CollegeMapperAssociation"

  def self.delete(*args)
    sws_log args.inspect, "Delete"
    self.prefix = "/api/v1/#{args.last[:params][:account_type]}/#{args.last[:params][:user_id]}/" if args.last.is_a?(Hash)
    self.post(args.first, {_method: "DELETE"})
  end
  
end
