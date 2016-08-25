require 'open-uri'

# Models an Institution record, pulled from the Department of Education's list. You must load the institutions list from a CSV file by calling +Institution#load_from_csv!+.
class Institution < ActiveRecord::Base
  include SchemaSearchable
  searchkick index_name: tenant_index_name, callbacks: :async

  has_many :college_applications, foreign_key: "institution_id"
  has_many :college_enrollments
  has_many :college_degrees
  has_many :interested_participants, -> { uniq }, class_name: "Participant", through: :college_applications, source: :participant
  has_many :applied_participants, -> { where("date_applied IS NOT NULL").uniq }, class_name: "Participant", through: :college_applications, source: :participant
  has_many :planning_participants, -> { uniq }, class_name: "Participant", foreign_key: "college_attending_id", source: :participant
  has_many :enrolled_participants, -> { uniq }, class_name: "Participant", through: :college_enrollments, source: :participant
  has_many :current_participants, -> { where(["began_on > ?", CollegeEnrollment::CURRENT_ENROLLMENT_VALIDITY_PERIOD.ago]).uniq }, class_name: "Participant", through: :college_enrollments, source: :participant
  has_many :graduated_participants, -> { uniq }, class_name: "Participant", through: :college_degrees, source: :participant

  alias_attribute :name, :instnm
  alias_attribute :title, :instnm
  alias_attribute :longitude, :longitud
  alias_attribute :address, :addr
  alias_attribute :street, :addr
  alias_attribute :state, :stabbr
  alias_attribute :county, :countynm
  alias_attribute :phone, :gentele
  alias_attribute :website_url, :webaddr
  
	ICLEVEL_DESCRIPTIONS = {
		"1" => "4-year college/university",
		"2" => "2-year college",
		"3" => "Less than 2-year college"
	}
  
  CONTROL_DESCRIPTIONS = {
    "1" =>	"Public",
    "2" =>	"Private not-for-profit",
    "3" =>	"Private for-profit",
    "-3" =>	"Not available"
  }
  
  SECTOR_DESCRIPTIONS = {
    "0" =>	"Administrative Unit",
    "1" =>	"Public, 4-year or above",
    "2" =>	"Private not-for-profit, 4-year or above",
    "3" =>	"Private for-profit, 4-year or above",
    "4" =>	"Public, 2-year",
    "5" =>	"Private not-for-profit, 2-year",
    "6" =>	"Private for-profit, 2-year",
    "7" =>	"Public, less-than 2-year",
    "8" =>	"Private not-for-profit, less-than 2-year",
    "9" =>	"Private for-profit, less-than 2-year",
    "99" =>	"Sector unknown (not active)"
  }
  
  self.primary_key = 'unitid'

  def geocoded?
    false
  end

  # Returns +unitid+ converted to Integer.
  def id
    unitid.to_i
  end

  # Override in case we're looking for a college with a
  # negative unitid
  def self.find(*args)
    if args.first.is_a?(Integer) && args.first < 0
      College.find(-args.first)
    else
      super(*args)
    end
  end
  
  # Strips out hyphens from OPEID before searching.
  def self.find_by_opeid(opeid)
    super(opeid.to_s.gsub("-", ""))
  end

	def to_title
		title
	end
  
  # Uses Addressable::URI.heuristic_parse to return a valid URL from the +webaddr+ attribute of this Institution.
  def formatted_website_url
    first_url = self.webaddr.is_a?(Array) ? self.webaddr.first : self.webaddr
    Addressable::URI.heuristic_parse(first_url).to_s
  end
  
  def search_result
    super.merge(url: Rails.application.routes.url_helpers.college_path(self))
  end
	
	attr_accessor :count
  
  # Returns an array of this institution's aliases, including the institution's name (stored in +instnm+).
  # This allows you to do a search on all names and aliases. If you want to see ONLY the aliases, pass
  # +false+ for the +:include_institution_name+ option.
  def aliases(options = { include_institution_name: true })
    aliases = []
    aliases << self[:name] if options[:include_institution_name]
    aliases << self[:ialias].split(",").split("|").flatten.collect(&:strip)
    aliases.flatten.compact
  end

  # Returns a string about the Institution location suitable as a subtitle, like "Seattle, WA"
  def location_detail
    [self.city, self.state].join(", ")
  end
	
	# Returns the ICLEVEL description for this Institution:
	#
	# 1: 	4-year college/university
	# 2: 	2-year college
	# 3: 	Less than 2-year college
	#
	# Any other values return nil
	def iclevel_description
		ICLEVEL_DESCRIPTIONS[iclevel.to_s]
	end
  
  # Returns the CONTROL description (public vs. private) for this Institution.
  def control_description
    CONTROL_DESCRIPTIONS[control.to_s]
  end

  # Returns the SECTOR description for this Institution, which is one of nine institutional
  # categories resulting from dividing the universe according to control and level. Control
  # categories are public, private not-for-profit, and private for-profit. Level categories
  # are 4-year and higher (4 year), 2-but-less-than 4-year (2 year), and less than 2-year.
  # For example: public, 4-year institutions.
  def sector_description
		SECTOR_DESCRIPTIONS[sector.to_s]
  end

  # Returns the URL of this institution's record in the IPED's CollegeNavigator system.
  def college_navigator_url
    "http://nces.ed.gov/collegenavigator/?id=" + id.to_s
  end
  
  # Attempts to fetch the CEEB code form the College Board website for this school.
  # Returns nil if College Board returns no results. If there's only a single result, returns just
  # that code. Otherwise, you'll get a hash of CEEB codes and college names as they are returned by
  # College Board.
  #
  # If needed, pass a different +name_value+ to try a slightly different version of the name in the
  # search.
  def ceeb_code_guess(name_value = self.name.gsub("-"," ").gsub("Campus",""), try_again_on_failure = true)
    uri = Addressable::URI.parse("http://sat.collegeboard.org/register/sat-code-search-schools")
    uri.query_values = {
      "decorator" => "none",
      "submissionMode" => "ajax",
      "pageId" => "registerCodeSearch",
      "codeType" => "college-code",
      "country" => "US",
      "state" => self.state,
      "collegeScholorshipName" => name_value.strip
    }
    url = uri.normalize.to_s
    puts "Fetching CEEB code results from #{url}"
    response = open(url).read
    document = Nokogiri::HTML(response)
    results = nil
    if document.xpath("//h3").text == "No Results"
      results = self.ceeb_code_guess(self.f1sysnam, false) if try_again_on_failure
      return results
    else
      results = {}
      codes = document.xpath("//tr[@class!='headerRow']/td[@class='codeResultCell']").collect(&:text).collect(&:to_i)
      names = document.xpath("//tr[@class!='headerRow']/td[@class='schoolResultCell']").collect(&:text)
      codes.each_with_index do |code, i|
        results[codes[i]] = names[i].strip
      end
      if results.empty?
        return nil
      elsif results.size == 1
        return results.keys.first
      else
        return results
      end
    end
  end
  
  # Finds all Institutions whose name or aliases match the search term supplied and returns an array
  # of Institution objects. If nothing is found, the method will try the search again with each word
  # in +search_term+ separated out and return an intersection of the results. By default, returns only
  # 100 results.
  def self.find_all_by_name(search_term, options = { try_separating_words_on_failure: true, limit: 100 })
    limit = options[:limit].is_a?(Integer) ? options[:limit] : options[:limit].to_i
    search_term = search_term.gsub /[\(\)\#\d,]?/, "" # strip out parentheses and numbers
    search_term = search_term.gsub /\s/, " " # strip out tabs and such
    first_try = Institution.where(["instnm LIKE :t OR ialias LIKE :t", t: "%#{search_term}%"])
    extra_colleges = College.where(["name LIKE ?", "%#{search_term}%"]).collect{|c| c.id = -c.id; c}
    first_try = [first_try + extra_colleges].flatten
    if first_try.empty?
      return [] unless options[:try_separating_words_on_failure] == true
    else
      return first_try[0..(limit-1)]
    end

    second_try = []
    for search_word in search_term.split(" ")
      second_try << Institution.find_all_by_name(search_word, { try_separating_words_on_failure: false })
    end
    second_try.inject(:"&").flatten.uniq[0..(limit-1)]
  end

  # Loads the institutions database from the CSV file provided. Specify the path of the file to load.
  # The file must conform to the format from IPEDS, which was last retrieved here:
  # https://inventory.data.gov/dataset/post-secondary-universe-survey-2010-directory-information/resource/38625c3d-5388-4c16-a30f-d105432553a4
  # The 2013 dataset is available in +/db/institutions-2013.csv+.
  #
  # This method will create institution records that don't exist, or update existing records
  # with new information. Thus, you should be able to re-run this command anytime IPEDS releases
  # a new data file.
  def self.load_from_csv!(file_path)
    input_arr = CSV.read(file_path, encoding: "ISO-8859-1:UTF-8") # convert to UTF-8
    headings = input_arr.shift
    input_arr.each do |inst|
      obj = Institution.find_or_initialize_by_unitid(inst[0])
      headings[1..headings.length].each_with_index do |col, index|
        next if col == "UNITID"
        obj[col.downcase] = inst[index+1]
      end
      obj.save
    end
  end
  
end
