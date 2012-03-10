class ObjectFilter < ActiveRecord::Base
  validates_presence_of :object_class, :title, :criteria
  
  # Returns true if the passed object passes the filter criteria using +instance_eval+.
  def passes?(object)
    object.instance_eval(criteria)
  end
  
end
