require 'nokogiri'

class UwDriver
  # Checks the UWFS website to see if the mentor has completed their training. Returns a
  # ruby hash with the keys:
  #  * error: Maps to a string if there was an error processing the request, nil otherwise
  #  * date: Maps to a ruby Time if a training date was found, nil otherwise
  #  * changed: Maps to true if a date was found and it differs from that on file, nil otherwise
  #  * saved: Maps to true if the date changed and the mentor record was successfully saved, nil otherwise
  def self.check_uwfs_training(mentor_id)
    result = {error: nil, date: nil, changed: nil, saved: nil}
    mentor = Mentor.find(mentor_id)
    doc = Nokogiri::HTML(open("http://www.washington.edu/facilities/transportation/fleetservices/training-lookup/" + mentor.uw_net_id))
    begin
      if (node = doc.xpath("//form[@id='basic-driver-training-lookup-form']/div/p/strong")[1])
        old = mentor.uwfs_training_date
        new = Time.parse(node.to_s)
	result[:date] = new
        if (old != new)
          result[:changed] = true
          mentor.uwfs_training_date = new
	  result[:saved] = mentor.save
        end
      end
    rescue Exception => e
      result[:error] = e.to_s
    end
    result
  end
end
