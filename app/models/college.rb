=begin
Models a College institution as a subclass of Location. Most Institution information is stored in the Institution class, which pulls form the national IPEDS database. This is used to store extra information about particular Institutions; in which case, the +institution_id+ attribute is used to link the two records. 

This model can also be used to store inforamtion for Institutions that do not exist in the IPEDS database, such as international colleges. That way this College can be assigned to a CollegeApplication object. When this is done, the CollegeApplication will use the negative value of the College#id. So if the College ID is 831, the CollegeApplication institution_id can be set to -831 and the Institution model will properly return the relevant College object.
=end
class College < Location
	validates_uniqueness_of :institution_id, allow_nil: true
	validates_presence_of :name

  has_many :college_applications, foreign_key: 'institution_id'

	# Overrides #find_one in case we receive a negative ID number. See note at College.
	def self.find_one(id, *args)
		super(id.abs, *args)
	end

	# Returns a string about the Institution location suitable as a subtitle, like "Seattle, WA"
	def location_detail
		[self.city, self.state, self.country].compact.join(", ")
	end

	def webaddr
		website_url
	end

  def formatted_website_url
    Addressable::URI.heuristic_parse(webaddr).to_s
  end

	def college_navigator_url
		nil
	end

  # IClevel always returns blank because College objects aren't connected to IPEDS.
    def iclevel
      ""
    end
    
  # IClevel always returns blank because College objects aren't connected to IPEDS.
  def iclevel_description
    ""
  end
    
end
