class TermResource < UwWebResource
  self.prefix = "/student/v5/"
  self.element_name = "term"
  self.collection_name = "term"
  self.caller_class = "TermResource"
  
  def self.find(*args)
    sws_log args.inspect, "Find"
    super
  end

end
