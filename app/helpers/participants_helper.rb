module ParticipantsHelper
  
  # Outputs the <li> tag and link that serves as a tab header. Won't display the tab if the
  # participant object doesn't respond to the collection_name passed.
  def link_to_section_li(participant, title, collection_name, dom_id, active = false)
    # return nil if !collection_name.nil? && !participant.respond_to?(:collection_name)
    link_title = title
    if collection_name
      count = participant.try("#{collection_name}_count") if participant.respond_to?("#{collection_name}_count")
      count ||= participant.instance_eval("#{collection_name}.count") if participant.respond_to?("#{collection_name}")
      link_title << content_tag(:span, count, :class => "count #{'zero' if count.zero?}") if count
      link_title << content_tag(:span, count, :class => "count-bar count-#{h(count)}") if count
    end
    content_tag :li, link_to_function(link_title, "switchToTab('#{dom_id}')", :class => "#{(active ? "active" : "")} #{dom_id}", :id => "#{dom_id}_tab_link")
  end
  
end
