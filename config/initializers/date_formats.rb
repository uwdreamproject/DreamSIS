my_formats = {
  :date_time12            => "%m/%d/%Y %I:%M%p",
  :date_time24            => "%m/%d/%Y %H:%M",
  :date_with_day_of_week  => "%A, %B %d, %Y",
  :date_with_full_month   => "%B %d, %Y",
  :time12                 => "%l:%M %p",
  :time_with_seconds      => "%H:%M:%S",
  :short_date             => "%m/%d/%Y",
  :month_year             => "%B %Y",
  :month_day              => "%B %d",
	:excel                  => lambda { |time| time.strftime("%Y-%m-%dT%H:%M:%S.000") }
}

Time::DATE_FORMATS.merge!(my_formats)
Date::DATE_FORMATS.merge!(my_formats)