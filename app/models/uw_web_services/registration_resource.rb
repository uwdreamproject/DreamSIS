class RegistrationResource < UwWebResource
  self.prefix = "/student/v4/"
  self.element_name = "registration"
  self.collection_name = nil
  self.caller_class = "RegistrationResource"
  
  def self.find(*args)
    sws_log args.inspect, "Find"
    super
  end

end