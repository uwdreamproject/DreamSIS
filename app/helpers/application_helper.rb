module ApplicationHelper

  def file_extension_from_content_type(content_type)
		extension = Rack::Mime::MIME_TYPES.invert[content_type] || ""
		extension = extension.dup.to_s
		extension.gsub!(".", "")    
  end

	# Creates an image tag with the icon for the requested MIME content type. Defaults to the 32px size.
	def file_icon_tag(content_type, size = "32")
		aliases = {
			:jpeg => :jpg,
			:docx => :doc
		}
		extension = Rack::Mime::MIME_TYPES.invert[content_type] || ""
		extension = extension.dup.to_s
		extension.gsub!(".", "")
		title = h "#{extension.upcase} file"
		extension = aliases[extension.to_sym].to_s if !extension.blank? && aliases[extension.to_sym]
    filename = ["icons", "Free-file-icons", "#{h(size)}px", "#{h(extension)}.png"]
    # extension = "_blank" unless File.exists?(image_path(File.join(filename)))
		image_tag File.join(filename), :title => title
	end  
  
  # Fetch the favicon for a requested site, like a college home page.
  def fetch_favicon_tag(url, options = {})
    return nil if url.blank?
    options.merge({ :size => 16 })
    url_parsed = Addressable::URI.heuristic_parse(h(url)).to_s
    # service_prefix = "https://getfavicon.appspot.com/" # this service is perpetually over quota :-(
    service_prefix = "https://www.google.com/s2/favicons?domain="
    image_url = service_prefix + url_parsed
    return image_url if options[:return_url_only] == true
    image_tag image_url, :width => options[:size], :height => options[:size]
  end

  # Print pretty phone numbers
  def number_to_phone_pretty(number, options = { })
    type = options[:type] || nil
    content_tag('span', number_to_phone(number, options), :class => "#{type} phone")
  end

  # Generate a collection of upcoming years for a dropdown
  def years_collection
    for year in (Time.now.year-2..Time.now.year+10) 
    end
  end
  
  def states
    states = {
      'WA' =>  'Washington',
      'OR' =>  'Oregon'
    }
  end

  # Creates a separator
  def separator(text = "or")
    content_tag :span, raw(" &ndash; ") + text + raw(" &ndash; "), :class => "separator"
  end

  # Creates a link that updates the specified form element with the current date and time when clicked.
  # By default, this will also include a "Clear" link to clear out the same element instead.
  def link_to_now(element_id, include_clear_link = true)
    str = ""
    str << link_to("Set to now", "#", :class => "link-to-now", "data-target" => element_id.to_s)
    if include_clear_link
      str << separator("or")
      str << link_to_clear(element_id)
    end
    raw(str)
  end
  
  # Creates a link that updates the specified form date element to all blanks when clicked.
  def link_to_clear(element_id)
    link_to "Clear", "#", :class => "link-to-clear", "data-target" => element_id.to_s
  end

	# Like the +pluralize+ method but doesn't include the number.
	def pluralize_without_number(number, noun)
		number == 1 ? noun : noun.pluralize
	end
  
  def default_form_actions(form)
    content_tag(:fieldset, :class => "actions") do
      content_tag(:ol) do
        form.action(:submit, :label => "Save") +
        content_tag(:li, separator, :class => "action") +
        form.action(:cancel, :label => "Cancel")
      end
    end
  end
  
  def default_form_errors(form)
    raise Exception.new("This helper method can only be used with Formtastic forms") unless form.is_a?(Formtastic::FormBuilder)
      unless form.object.errors.empty?
        content_tag :div, :class => "errorExplanation" do
          concat content_tag(:h2, "There are some problems with this record.")
          concat content_tag(:p, "Please correct the errors below and try to save the record again.")
          concat form.semantic_errors(*form.object.errors.keys)
        end
      end
  end
  
  def date_interval_tag(date1, date2)
    return nil if date1.nil? || date2.nil?
    date1 = date1.to_date
    date2 = date2.to_date
    days_diff = (date1 - date2).to_i
    if days_diff < 7
      return nil
    elsif days_diff < 14
      klass = "short"
      output = distance_of_time_in_words(date1, date2)
    elsif days_diff < 30
      klass = "medium"
      output = distance_of_time_in_words(date1, date2)
    else
      klass = "long"
      output = distance_of_time_in_words(date1, date2)
    end
    content_tag(:div, output, :class => "date-interval #{klass}")
  end
  
end
