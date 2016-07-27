module ParticipantsHelper
  
  # Outputs the <li> tag and link that serves as a tab header. Won't display the tab if the
  # participant object doesn't respond to the collection_name passed.
  def link_to_section_li(participant, title, collection_name, dom_id, active = false)
    # return nil if !collection_name.nil? && !participant.respond_to?(:collection_name)
    link_title = title
    if collection_name
      count = participant.try("#{collection_name}_count") if participant.respond_to?("#{collection_name}_count")
      count ||= participant.try(&collection_name).try(&:count) if participant.respond_to?("#{collection_name}")
      badge = content_tag(:span, "#{count.to_i}", class: "badge #{'zero' if count.zero?}") if count
      link_title = safe_join([link_title, badge], " ")
    end
    content_tag :li, class: "#{'active' if active}", role: "presentation" do
      link_to link_title, "##{dom_id}", aria: { controls: dom_id }, role: "tab", data: { toggle: "tab" }
    end
  end
  
  # Outputs the link tag for triggering a bulk action. Specify the action to trigger as the main
  # parameter, and an optional "class" option to assign to the link tag.
  def link_to_participant_bulk_action(title, action_name, options = { })
    options.merge!({
      "data-original-href" => participant_bulk_action_path(action_name),
      "data-extra-params" => options.delete(:extra_params),
      class: "#{options.delete(:class)} button",
      remote: true,
      method: :post
    })
    link_to title, participant_bulk_action_path(action_name), options
  end
  
  # Generates the URL for requesting an XLSX report based on the current location.
  def xlsx_url(force_generate = false)
    url = { format: :xlsx }
    url[:report] = params[:report] if params[:report]
    url[:action] = 'index' if controller.action_name == 'index'
    url[:generate] = 'true' if force_generate
    return url
  end

  def filter_warning_count_tag(participant)
    count = @filter_warning_counts[participant.id.to_s]
    return "" if count.nil? || count.to_i.zero?
    content_tag(:a, count, class: "filter_results_count", href: "")
  end
  
end
