class GroupResource < NonstandardWebServiceResult
  
  GWS_VERSION = "v2"

  self.site = "https://iam-ws.u.washington.edu:7443"
  self.element_path = "group_sws/#{GWS_VERSION}/group"  
  self.cache_lifetime = 1.hour
  
  # Specify the stem that should be used. Methods in this class will check that the requested group name
  # begins with this stem. Therefore when using these methods you can specify either the full group name
  # or just the part after this main stem. In other words, the following calls are equivalent:
  # 
  # * GroupResource.find("u_uwdrmprj_mentors_autumn2011")
  # * GroupResource.find("mentors_autumn2011")
  GROUP_STEM = "u_uwdrmprj_"

  # Creates a new group using the specified group_identifier. After creating, it looks up the group and
  # returns its GroupResource object.
  def self.create(group_identifier, options = {})
    group_identifier = GroupResource.prep_group_identifier(group_identifier)
    options = { :name => group_identifier.titleize }.merge(options)
    # puts GroupResource.new_group_xhtml(group_identifier, options)
    connection.put(self.element_path + "/#{group_identifier}", GroupResource.new_group_xhtml(group_identifier, options))
    GroupResource.find(group_identifier)
  end

  # Tries to find a group using the group_identifier, but if it doesn't exist, creates it using the options passed.
  def self.find_or_create(group_identifier, options = {})
    group_identifier = GroupResource.prep_group_identifier(group_identifier)
    g = GroupResource.find(group_identifier)
    g.nil? ? GroupResource.create(group_identifier, options) : g
  end

  def self.find(group_identifier)
    super(GroupResource.prep_group_identifier(group_identifier))
  end

  # Adds a member to this group. Pass a single UW NetID or an array of them.
  # Returns true if all members were added to the group. Returns an array of members not found.
  def add_member(uwnetids)
    uwnetids = uwnetids.join(",") if uwnetids.is_a?(Array)
    result = Nokogiri::HTML(connection.put(constructed_path + "/member/#{uwnetids}").body)
    notfound = result.xpath("//span[@class='notfoundmember']").children
    if notfound.empty?
      return true
    else
      return notfound.collect(&:text)
    end
  end
  
  # Updates the membership list; i.e., replace the current membership with the array of UW Netids.
  # Returns true if all members were added to the group. Returns an array of members not found.
  def update_members(uwnetids)
    t = connection.timeout
    connection.timeout = 30
    request = connection.put(constructed_path + "/member", update_members_xhtml(uwnetids), { "If-Match" => "*"})
    connection.timeout = t
    result = Nokogiri::HTML(request.body)
    notfound = result.xpath("//span[@class='notfoundmember']").children
    if notfound.empty?
      return true
    else
      return notfound.collect(&:text)
    end 
  end
  
  # Delete a member to this group. Pass a single UW NetID or an array of them.
  # Returns true if all members were deleted from the group.
  def delete_member(uwnetids)
    uwnetids = uwnetids.join(",") if uwnetids.is_a?(Array)
    result = Nokogiri::HTML(connection.delete(constructed_path + "/member/#{uwnetids}").body)
    notfound = result.xpath("//span[@class='notfoundmember']").children
    if notfound.empty?
      return true
    else
      return notfound.collect(&:text)
    end
  end

  # Returns true if all the given id or ids is a member of the group. Returns false if any are not.
  def is_member?(uwnetids)
    uwnetids = uwnetids.join(",") if uwnetids.is_a?(Array)
    return connection.get(constructed_path + "/member/#{uwnetids}") ? true : false
  end
  
  # Returns the member_ids for all members of this group. By default, this will fetch the effective members
  # of the group. To bypass this and only return the regular members of the group, pass +false+ as the parameter.
  def member_ids(get_effective_members = true)
    resource_name = get_effective_members ? "effective_member" : "member"
    result = Nokogiri::HTML(connection.get(constructed_path + "/#{resource_name}")) unless @members
    @members ||= result.xpath("//*[@class='#{resource_name}']").children.collect(&:text)
  end
  
  # Returns the raw payload from the groups service for all members of this group. By default, this will fetch the effective members
  # of the group. To bypass this and only return the regular members of the group, pass +false+ as the parameter.
  def members_raw(get_effective_members = true)
    resource_name = get_effective_members ? "effective_member" : "member"
    result = Nokogiri::HTML(connection.get(constructed_path + "/#{resource_name}")) unless @members_raw
    @members_raw ||= result.xpath("//*[@class='#{resource_name}']") #.children.collect(&:text)
  end

  protected
  
  # Checks to make sure that the supplied parameter starts with the +GROUP_STEM+ (like "u_uwdrmprj_")
  # and adds it at the beginning if needed. This method avoids the need for hard-coding the group prefix throughout.
  def self.prep_group_identifier(group_identifier)
    group_identifier = GROUP_STEM + group_identifier unless group_identifier.starts_with?(GROUP_STEM)
    group_identifier
  end
  
  # Prepares the XHTML for a new group request from the web service. The template is stored in
  # Rails.root/app/views/web_services/group/new.html.erb
  def self.new_group_xhtml(group_identifier, options = {})
    @group_identifier = group_identifier
    @options = options
    ERB.new(File.read(File.join(Rails.root, "app", "views", "web_services", "group", "new.html.erb"))).result(binding)
  end

  # Prepares the XHTML for a request to update the group members. The template is stored in
  # Rails.root/app/views/web_services/group/update_members.html.erb
  def update_members_xhtml(members)
    @members = members
    ERB.new(File.read(File.join(Rails.root, "app", "views", "web_services", "group", "update_members.html.erb"))).result(binding)
  end


end