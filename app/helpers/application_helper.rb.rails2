# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def breadcrumbs(sep = ">>")
    levels = request.path.split('?')[0].split('/')
    levels.delete_at(0)

    links = ""
    levels.each_with_index do |level, index|
      links += " #{sep} #{content_tag('a', level.downcase.gsub(/_/, ' '), :href => '/'+levels[0..index].join('/'))}"
    end

    content_tag("div", content_tag("p", links ), :id => "breadcrumb")
  end

  def field_with_label(form_field, label = "")
  	form_field_name = form_field.scan(/name=\"(.*?)\"/)
  	form_field_name_short = form_field_name[0][0].scan(/\[(.*?)\]/)[0][0]
	  if label.blank? then label = form_field_name_short.capitalize end
  	"<label for='#{form_field_name}'>#{label}</label>#{form_field}<br />"
	end
  
  def submit_tag_text
    case controller.action_name
    when 'edit': "Save changes"
    when 'new': "Save new record"
    end
  end
  
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
		extension = "_blank" unless File.exists?(RAILS_ROOT + "/public/images/icons/Free-file-icons/#{h(size)}/#{h(extension)}.png")
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
    "<span class=\"separator\"> &ndash; #{text} &ndash; </span>"
  end

  # Creates a link that updates the specified form element with the current date and time when clicked.
  # By default, this will also include a "Clear" link to clear out the same element instead.
  def link_to_now(element_id, include_clear_link = true)
    str = ""
    str << @template.link_to_function("Set to now", "setToNow('#{element_id.to_s}')")
    if include_clear_link
      str << separator("or")
      str << link_to_clear(element_id)
    end
    str
  end
  
  # Creates a link that updates the specified form date element to all blanks when clicked.
  def link_to_clear(element_id)
    @template.link_to_function "Clear", "setToClear('#{element_id.to_s}')"
  end

	# Like the +pluralize+ method but doesn't include the number.
	def pluralize_without_number(number, noun)
		number == 1 ? noun : noun.pluralize
	end
  
  def calendar(date = Date.today, &block)
    @template.concat(Calendar.new(@template, date, block).table)
  end
  
end
