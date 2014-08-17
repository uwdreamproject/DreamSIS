module ApplicationHelper

	# Creates an image tag with the icon for the requested MIME content type. Defaults to the 32px size.
	def file_icon_tag(content_type, size = "32px")
		aliases = {
			:jpeg => :jpg,
			:docx => :doc
		}
		extension = Rack::Mime::MIME_TYPES.invert[content_type] || ""
		extension = extension.dup.to_s
		extension.gsub!(".", "")
		title = h "#{extension.upcase} file"
		extension = aliases[extension.to_sym].to_s if !extension.blank? && aliases[extension.to_sym]
		extension = "_blank" unless File.exists?(Rails.root + "/public/images/icons/Free-file-icons/#{h(size)}/#{h(extension)}.png")
		image_tag "icons/Free-file-icons/#{h(size)}/#{h(extension)}.png", :title => title
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
  
  def calendar(date = Date.today, &block)
    @template.concat(Calendar.new(@template, date, block).table)
  end
  
end
