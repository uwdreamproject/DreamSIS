class HighSchool < Location

  default_scope { order("name") }
  scope :partners, -> { where(partner_school: true) }

  has_many :participants do
    def in_participating_cohort(term)
      find_all_by_grad_year term.participating_cohort
    end
  end
  
  has_many :visits, foreign_key: 'location_id' do
    def for(term)
      find_all {|visit| term.include?(visit.date)}
    end
  end

  has_many :mentor_term_groups , foreign_key: 'location_id' do
    def for(term)
      find_all_by_term_id term.id
    end
  end
  
  # Returns an array of unique graudation years
  def cohorts
    @cohorts ||= participants.pluck(:grad_year).uniq.compact.sort.reverse
  end

  # Attempts to fetch the CEEB code form the College Board website for this school.
  # Returns nil if College Board returns no results. Returns a hash of CEEB codes and high school
  # names as they are returned by College Board. Unfortunately, the College Board only lets you
  # limit high school code searches to city (not school name), so this best guess will often return
  # many guesses. This method differs from Institution#ceeb_code_guess in that it always returns the
  # hash of results, even if there's only one result.
  #
  # If needed, pass a different +name_value+ to try a slightly different version of the name in the
  # search.
  def ceeb_code_guess(name_value = self.name, try_again_on_failure = false)
    uri = Addressable::URI.parse("http://sat.collegeboard.org/register/sat-code-search-schools")
    uri.query_values = {
      "decorator" => "none",
      "submissionMode" => "ajax",
      "pageId" => "registerCodeSearch",
      "codeType" => "high-school-code",
      "country" => "US",
      "state" => self.state || "WA",
      "city" => self.city
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
        return results
      else
        return results
      end
    end
  end

  # Returns all high schools in a Hash with district name for keys and an array of schools for values.
  def self.all_by_district(options = {})
    @all_by_district = {}
    @all_by_district[options[:prompt]] = [] if options[:prompt]
    for hs in self.all
      @all_by_district[hs.district.to_s] ||= []
      @all_by_district[hs.district.to_s] << hs
    end
    @all_by_district
  end


  
end
