module ActionView
  module Helpers
    module DateHelper

      # Provides a relative timestamp for the specified date/time as follows:
      # 
      # * for times in the coming 30 minutes: "16 minutes from now"
      # * for times in the last 30 minutes: "16 minutes ago" (uses time_ago_in_words)
      # * for times today: "7:38 pm"
      # * for times yesterday: "Yesterday at 3:15 pm"
      # * for times tomorrow: "Tomorrow at 3:15 pm"
      # * for times less than a week ago: "Wednesday at 4:23 pm"
      # * for times less than a year ago: "Mar 13th at 11:32 am"
      # * other times: "05/28/2003 at 12:45 pm"
      # 
      # Options include:
      # * Specify a +separator+ to use between the day and time if you'd like. It defaults to "at". This could be used to insert
      #   a "<br>" or other separator for use with HTML output.
      # * If +date_only+ is set to true, only the first part will be returned.
      # * +empty_string+ will be used if the date passed is nil. Defaults to "unknown".
      def relative_timestamp(from_time, user_options = {})
        user_options = { :separator => user_options } if user_options.is_a?(String)
        options = { :separator => "at", :empty_string => "unknown" }.merge(user_options)
        return options[:empty_string] if from_time.nil?
        time_alone = from_time.midnight == from_time ? "" : "#{options[:separator]} %I:%M #{from_time.ampm}"
        time_alone = "" if options[:date_only]
        if from_time > Time.now
          if    from_time < 30.minutes.from_now then time_ago_in_words(from_time) + " from now"
          elsif from_time.today? && options[:date_only] then "Today"
          elsif from_time.today?                then from_time.strftime("%I:%M #{from_time.ampm}")
          elsif from_time.to_date == Time.now.to_date.tomorrow
                                                then from_time.strftime("Tomorrow #{time_alone}")
          else                                       from_time.strftime("%m/%d/%Y #{time_alone}")
          end
        else
          if    from_time > 30.minutes.ago  then time_ago_in_words(from_time) + " ago"
          elsif from_time.today? && options[:date_only] then "Today"  
          elsif from_time.today?            then from_time.strftime("%I:%M #{from_time.ampm}")
          elsif from_time.to_date == Time.now.to_date.yesterday 
                                            then from_time.strftime("Yesterday #{time_alone}") 
          elsif from_time > 1.week.ago      then from_time.strftime("%A #{time_alone}")
          elsif from_time > 1.year.ago      then from_time.strftime("%b #{from_time.day.ordinalize} #{time_alone}")
          else                                   from_time.strftime("%m/%d/%Y #{time_alone}")
          end
        end
      end
      
    end
  end
end

class Time
  
  def ampm
    hour < 12 ? "am" : "pm"
  end
  
end

class DateTime
  
  def ampm
    hour < 12 ? "am" : "pm"
  end
  
end