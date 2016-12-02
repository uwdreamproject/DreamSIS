# This module contains helpers that are useful for working with Bootstrap in our Rails app.
module BootstrapHelper

  # Simple wrapper for inserting a glyphicon
  def glyph(key, text = "", options = {})
    content_tag(:i, "", {
      class: "fa fa-#{h(key.to_s)} #{h(options[:class])}",
      aria: { hidden: true, label: h(text) }
    } ) + " "
  end

  def nav_dropdown(title, &block)
    content_tag :li, class: "dropdown" do
      title_with_caret = "".html_safe + title + " <span class='caret'></span>".html_safe
      link_to(title_with_caret, "#", class: "dropdown-toggle", data: { toggle: "dropdown" }, role: "button", aria: { haspopup: true, expanded: false }) +
      content_tag(:ul, class: "dropdown-menu") do
        capture(&block)
      end
    end
  end

  # Overrides +link_to+ to support a +glyph+ option. If provided, the glyph
  # icon will be prepended to the link text.
  def link_to(name = nil, options = nil, html_options = nil, &block)
    if html_options.try(:[], :glyph)
      name = glyph(html_options.delete(:glyph) + " fa-fw") + name
      super(name, options, html_options, &block)
    else
      super
    end
  end
  
  # Prints out breadcrumbs in a Bootstrap friendly way, trying to best-guess each element
  def breadcrumbs(*args)
    content_for(:breadcrumbs) do
      content_tag(:ol, class: "breadcrumb") do
        for arg in args
          if arg.is_a?(String)
            concat content_tag(:li, arg, class: "active")
          elsif arg.is_a?(Symbol)
            concat content_tag(:li, link_to(arg.to_s.titleize, arg))
          elsif arg.is_a?(Array)
            title = arg.last.is_a?(Symbol) ? arg.last.to_s.titleize : guess_label_text(arg.last)
            concat content_tag(:li, link_to(title, arg))
          elsif arg.is_a?(ActiveRecord::Relation)
            concat(content_tag(:li, class: "dropdown") do
              concat(content_tag(:a, :class => "dropdown-toggle", "data-toggle" => "dropdown") do
                concat(guess_label_text( arg.select{|a| @term ? a == @term : current_page?(a) }))
                concat(" ")
                concat(content_tag(:span, "", class: "caret"))
              end)
              concat(content_tag(:ul, class: "dropdown-menu") do
                for object in arg
                  active = @term ? object == @term : current_page?(object)
                  path = arg.klass.is_a?(Term) ? url_for(term: object) : object
                  path = url_for(term: object)
                  concat(content_tag(:li, link_to(guess_label_text(object), path), class: ("active" if active)))
                end
              end)
            end)
          else
            concat content_tag(:li, link_to(guess_label_text(arg), arg))
          end
        end
      end
    end
  end
  
  def operations(options = {}, &block)
    options = { wrap: true }.merge(options) if options.respond_to?(:merge) # wrap in an .btn-group div
    content_for(:operations) do
      if block_given?
        content = capture(&block)
        options[:wrap] ? content_tag(:div, content, class: "btn-group", role: "group", aria: { label: "Operations Links" }) : content
      elsif options.is_a?(Array)
        for link in options
          case link
          when :save then concat link_to("Save", "", data: { submit: 'main' }, class: "btn btn-default")
          end
        end
      end
    end
  end
  
  def subheader(options = {}, &block)
    content_for(:subheader) do
      capture(&block)
    end
  end
  
  def guess_label_text(arg)
    return guess_label_text(arg.last) if arg.is_a?(Array)
    methods = [:to_label, :fullname, :name, :title]
    arg.try(methods.find{ |m| arg.respond_to?(m) }) rescue nil
  end

  def modal(id, &block)
    content_for :modals do
      content_tag :div, class: "modal fade", tabindex: "-1", role: "dialog", id: "modal-#{id.to_s.dasherize}", aria: { labelledby: id } do
        content_tag :div, class: "modal-dialog", role: "document" do
          content_tag :div, capture(&block), class: "modal-content"
        end
      end
    end
  end

end
