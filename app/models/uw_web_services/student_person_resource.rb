class StudentPersonResource < UwWebResource
  self.prefix = "/student/v5/"
  self.element_name = "person"
  self.collection_name = "person"
  self.primary_key = "UWRegID"
  self.caller_class = "StudentPersonResource"
  
  # Due to conflict in the TestScore attribute of the payload with the TestScore
  # model, creates new http request, changes TestScore attribute to TS in
  # the response payload, then creates manually creates a new StudentPersonResource
  def self.find(*args)
    uri = URI.parse("#{self.site}" + "#{self.prefix}" + "/" + "#{self.element_name}" + "/" + args.first+".json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.cert = ssl_options[:cert]
    http.key = ssl_options[:key]
    http.ca_file = ssl_options[:ca_file]
    http.verify_mode = ssl_options[:verify_mode]
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    payload = JSON.parse(response.body)
    test_score = payload["TestScore"]
    payload.delete("TestScore")
    payload["TS"] = test_score
    return StudentPersonResource.new(payload)
  end
  
  # def self.find_by_uwnetid(uwnetid)
  #   results = self.find(nil, :params => {:uwnetid => uwnetid})
  #   return nil if results.Persons.nil?
  #   self.find results.Persons.Person.PersonURI.UWRegID
  # end
  
  def photo
    @photo ||= StudentPhoto.new(id)
  end

  # Returns a hash of course meetings for the specified Term in the same format as CourseResource#meetings.
  def course_meetings(term)
    @course_meetings ||= {}
    return @course_meetings[term] if @course_meetings[term]
    cm = {}
    for meetings in active_registrations(term).collect{|reg| reg.course_resource.meetings }
      meetings.each do |day,meets|
        cm[day] ||= []
        cm[day] << meets
        cm[day].flatten!
      end
    end
    @course_meetings[term] = cm
  end

  # Returns the active RegistrationResource objects for this student for the specified Term.
  def active_registrations(term)
    params = { :reg_id => self.RegID, :is_active => "on" }
    params[:year] = term.year if term
    params[:quarter] = term.quarter_title if term
    registrations = RegistrationResource.find(:all, :params => params)
  end
  
end
