module GeneratorIfBlocks
  # Produces _if_ block, e.g.
  #
  #   page.if "$('element_id').visible()" do
  #     page['element_id'].hide
  #   end
  #
  # will produce
  #
  #    if( $('element_id').visible() ) {
  #      $("element_id").hide()
  #    }
  #
  # You can simplify if expression by using element proxies:
  #
  #    page.if page['element_id'].visible do
  #      page['element_id'].hide
  #    end
  #
  def if(expression)
    self << "if( #{ javascript_for(expression) } ) {"
    yield if block_given?
    self << "}"
  end

  # Same as +if+ method, but produces _if_not_ block
  def unless(expression)
    self << "if( !( #{javascript_for(expression) } ) ) {"
    yield if block_given?
    self << "}"
  end

  # Close javascript block and open an 'else' block
  def else
    self << "} else {"
  end

  protected

  def javascript_for(o)
    o.respond_to?(:to_script) ? o.to_script : o.to_s
  end
end
