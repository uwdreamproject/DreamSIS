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
      name = glyph(html_options.delete(:glyph)) + name
      super(name, options, html_options, &block)
    else
      super
    end
  end
  
end
