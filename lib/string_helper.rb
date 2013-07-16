
class String
  # def html_safe
  #   ActionController::Base.helpers.sanitize(self)
  # end
  
  def is_integer?
    !(self =~ /\A[+-]?\d+\Z/).nil?
  end
end
