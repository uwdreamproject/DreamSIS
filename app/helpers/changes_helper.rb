module ChangesHelper
  
  def prep_change_value(val)
    if val.nil?
      s = "nil"
      t = "nil"
    elsif val.is_a?(String)
      s = "&ldquo;#{h(val)}&rdquo;"
      t = "string"
    elsif val.is_a?(Numeric)
      s = val.to_s
      t = "number"
    elsif val.is_a?(Date)
      s = val.to_s(:long)
      t = "date"
    elsif val.is_a?(TrueClass) || val.is_a?(FalseClass)
      s = val.to_s
      t = "boolean"
    else
      s = "&ldquo;#{h(val.to_s)}&rdquo;"
      t = ""
    end
    
    return content_tag(:code, s, :class => "change_value #{t}")
  end
  
end