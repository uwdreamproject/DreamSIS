require 'open-uri'

class UwCalendar
  RESULTS_CACHE = FileStoreWithExpiration.new("tmp/cache/uw_calendar")
  
  # Fetches the holidays hash from the cache or regenerates them if needed. Pass :force => true to force
  # this method to requery the holidays from the calendar. Returns a hash of all the holidays found, with
  # the event date as keys and a hash of properties as values. This properties hash includes:
  # 
  # * start_date: event start
  # * end_date: event end (should be the same as start_date for holidays)
  # * title: The title of the event
  # * properties: The original raw properties hash from the original XML export
  def self.holidays(options = {})
    RESULTS_CACHE.fetch("holidays", {:expires_in => 30.days}.merge(options)) do
      self.fetch_holidays
    end
  end
  
  # Returns true if the passed date is in the list of UW holidays.
  def self.is_holiday?(date)
    holidays.keys.include?(date)
  end
  
  protected
  
  # Fetches the the holidays from the calendar service at http://myuw.washington.edu/cal/doExport.rdo.
  # Pulls holidays from a year ago to a year from now.
  def self.fetch_holidays
    query_params = {"export.action" => "execute",
                    "export.format" => "xml",
                    "export.compress" => "false",
                    "export.name" => "Holidays",
                    "export.start.date" => 1.year.ago.strftime("%Y%m%d"),
                    "export.end.date" => 1.year.from_now.strftime("%Y%m%d") }
    url = "http://myuw.washington.edu/cal/doExport.rdo?"
    url += query_params.collect{|k,v| "#{k}=#{v}" }.join("&")
    puts "Fetching calendar holidays from #{url}"
    response = open(url).read
    h = Hash.from_xml(response)
    holidays = {}
    for event in h["VCALENDAR"]["Components"]["VEVENT"]
      properties = event["Properties"]
      params = {}
      params[:start_date] = Date.parse(properties["DTSTART"]["value"])
      params[:end_date]   = Date.parse(properties["DTEND"]["value"])
      params[:title]      = properties["SUMMARY"]["value"]
      params[:properties] = properties
      holidays[params[:start_date]] = params
    end
    holidays
  end
  
end

class Date
  def is_holiday?
    UwCalendar.is_holiday?(self)
  end
end