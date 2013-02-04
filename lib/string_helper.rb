
class String
  def html_safe
    ActionController::Base.helpers.sanitize(self)
  end
end
