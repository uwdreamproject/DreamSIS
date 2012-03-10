my_formats = {
  :date_time12            => "%m/%d/%Y %I:%M%p",
  :date_time24            => "%m/%d/%Y %H:%M",
  :date_with_day_of_week  => "%A, %B %d, %Y",
  :date_with_full_month   => "%B %d, %Y",
  :time12                 => "%l:%M %p",
  :time_with_seconds      => "%H:%M:%S",
  :short_date             => "%m/%d/%Y"
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_formats)