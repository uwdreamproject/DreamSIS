require 'open-uri'

# Models an Institution record, pulled from the Department of Education's list.
class Institution
  RESULTS_CACHE = FileStoreWithExpiration.new(File.join(RAILS_ROOT, "files", "institution", "cache"))
  EXPIRATION = 30
  ATTRIBUTE_ALIASES = {
    :instnm    => [:name, :title],
    :longitud  => [:longitude],
    :addr      => [:address, :street],
    :stabbr    => [:state],
    :countynm  => [:county],
    :gentele   => [:phone],
    :webaddr   => [:website_url]
  }

  def geocoded?
    false
  end

  def initialize(raw_attributes)
    @raw_attributes = raw_attributes
    self
  end
  
  # Returns +unitid+ converted to Integer.
  def id
    unitid.to_i
  end
	
	def to_title
		title
	end
  
  def [](attribute)
    matching_aliases = self.class::ATTRIBUTE_ALIASES.collect{|k,v| k unless v.select{|a| a.to_s == attribute.to_s}.empty?}.compact
    aliases = ([attribute.to_s] + matching_aliases).flatten.compact
    for a in aliases
      return @raw_attributes[a.to_sym] if @raw_attributes[a.to_sym]
    end
    nil
  end
  
  # Overrides #method_missing so that you can access attributes as method call. Uses the +[]+ method to facilitate.
  # If +[]+ returns nil, then +super+ is called and a normal NoMethodError is raised.
  def method_missing(method, *args)
    self[method] || super
  end
  
  # Returns an array of this institution's aliases, including the institution's name (stored in +instnm+).
  # This allows you to do a search on all names and aliases. If you want to see ONLY the aliases, pass
  # +false+ for the +:include_institution_name+ option.
  def aliases(options = { :include_institution_name => true })
    aliases = []
    aliases << self[:name] if options[:include_institution_name]
    aliases << self[:ialias].split(",").split("|").flatten.collect(&:strip)
    aliases.flatten.compact
  end

  # Returns a string about the Institution location suitable as a subtitle, like "Seattle, WA"
  def location_detail
    [self.city, self.state].join(", ")
  end

  # Finds an Intitution record by "unitid" (the unique identifier provided by Dept of Ed's API).
  # If a negative integer is provided, this will find a College object instead (see note at College).
  def self.find(unitid)
    fancy_log ":unitid => #{unitid}", "Find"
		return nil if unitid.blank?
    if unitid.is_a?(Integer) && unitid < 0
      College.find(-unitid)
    else
      index_by_unitid[unitid.to_i]
    end
  end

  # Finds an Intitution record by "opeid" (the OPE ID from Dept of Ed's API). The method will convert
  # the parameter to an Integer so you can pass a String or an Integer. It will also strip out any
  # hyphens, which are often placed to separate the branch number.
  def self.find_by_opeid(opeid)
    fancy_log ":opeid => #{opeid}", "Find"
    opeid = opeid.gsub("-", "")
    index_by_opeid[opeid.to_i]
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
  def self.find_all_by_name(search_term, options = { :try_separating_words_on_failure => true, :limit => 100 })
    fancy_log ":name => '#{search_term}'", "Find"
    limit = options[:limit].is_a?(Integer) ? options[:limit] : options[:limit].to_i
    search_term = search_term.gsub /[\(\)\#\d,]?/, "" # strip out parentheses and numbers
    search_term = search_term.gsub /\s/, " " # strip out tabs and such
    first_try = index_by_name.select{ |key,value| key.include?(search_term.downcase)}.collect{ |key, value| value }.flatten.uniq
    extra_colleges = College.find(:all, :conditions => ["name LIKE ?", "%#{search_term}%"]).collect{|c| c.id = -c.id; c}
    first_try = [first_try + extra_colleges].flatten
    if first_try.empty?
      return [] unless options[:try_separating_words_on_failure] == true
    else
      return first_try[0..(limit-1)]
    end
    
    second_try = []
    for search_word in search_term.split(" ")
      second_try << Institution.find_all_by_name(search_word, { :try_separating_words_on_failure => false })
    end
    second_try.inject(:"&").flatten.uniq[0..(limit-1)]
  end
  
  # Returns an array of all Institutions as objects and caches the data for quick retrieval.
  def self.all(options = {})
    fancy_log ":all", "Find"
    @all ||= RESULTS_CACHE.fetch("all_objects", {:expires_in => 180.days}.merge(options)) do
      all = []
      for unitid,raw_attributes in Institution.raw_dataset(options)
        all << Institution.new(raw_attributes)
      end
      all
    end
  end
  
  # Replicates the behavior of a has_many association.
  def college_applications
    @college_applications ||= CollegeApplication.find :all, :conditions => { :institution_id => id }
  end
  
  protected
  
  def self.indexes(options = {})
    @indexes ||= RESULTS_CACHE.fetch("indexes", {:expires_in => 180.days}.merge(options)) do
      fancy_log ":all", "Index"
      indexes = { :unitid => {}, :opeid => {}, :name => {}}
      for object in Institution.all(options)
        indexes[:unitid][object[:unitid].to_i] = object
        indexes[:opeid][object[:opeid].to_i] = object
        for a in object.aliases
          indexes[:name][a.downcase] ||= []
          indexes[:name][a.downcase] << object
        end
      end
      indexes
    end
  end
  
  # Generates an index for faster searching by ID and stores it in the cache. Returns a hash with 
  # unitid as keys (converted to Integer) and Institution objects as values.
  def self.index_by_unitid(options = {})
    self.indexes(options)[:unitid]
  end

  # Generates an index for faster searching by OPE ID and stores it in the cache. Returns a hash with 
  # OPE IDs as keys (converted to Integer) and Institution objects as values.
  def self.index_by_opeid(options = {})
    self.indexes(options)[:opeid]
  end

  # Generates an index for faster searching by name/alias and stores it in the cache. Returns a hash with 
  # alias/names (converted to downcase) as keys and arrays of Institution objects as values.
  def self.index_by_name(options = {})
    self.indexes(options)[:name]
  end
  
  # Fetches the institutions listing from http://explore.data.gov/api/views/uc4u-xdrd/rows.json
  # and stores it as a hash of hashes into the RESULTS_CACHE. The hash keys are the "unitid" identifiers
  # for the school and the hash values are the raw data hashes returned from the API.
  def self.raw_dataset(options = {})
<<<<<<< HEAD
    RESULTS_CACHE.fetch("raw_data", {:expires_in => EXPIRATION.days}.merge(options)) do
=======
    RESULTS_CACHE.fetch("raw_data", {:expires_in => 180.days}.merge(options)) do
>>>>>>> 0f39a080654aa7a9183d10be1d530b468d2dbb29
      url = "http://explore.data.gov/api/views/uc4u-xdrd/rows.json"
      fancy_log ":raw_data => #{url}", "Fetch"
      puts "Fetching institution directory listing dataset from #{url}"
      response = open(url).read
      self.convert_to_hashes ActiveSupport::JSON.decode(response)
    end
  end
  
  # Takes the json object returned from the API and returns a hash of raw data using the "unitid" field as the key.
  def self.convert_to_hashes(json)
    field_names = json["meta"]["view"]["columns"].collect{|c| c["fieldName"].to_sym }
    data = {}
    for record in json["data"]
      hash = {}
      field_names.each_with_index do |field_name, index|
        hash[field_name] = record[index]
      end
      data[hash[:unitid]] = hash
    end
    data
  end

  def self.fancy_log(msg, method = "Fetch", time = nil)
    caller_class_s = "Institution"
    message = "  \e[4;33;1m#{caller_class_s} #{method}"
    message << " (#{'%.1f' % (time*1000)}ms)" if time
    message << "\e[0m   #{msg}"
    RAILS_DEFAULT_LOGGER.info message
  end

  
end

