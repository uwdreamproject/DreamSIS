class HelpText < ApplicationRecord
  attr_accessible :attribute_name, :instructions, :object_class, :title, :hint, :audience
  validates_uniqueness_of :attribute_name, scope: [:object_class, :audience]
  
  def self.for(object_class, attribute_name, audience = nil)
    HelpText.for_object_class(object_class.to_s, audience)[attribute_name.to_s] 
  end

  # Returns the HelpText for the specified object class, scoped to the requested audience
  # if possible. To do this, we simply run a query where `audience` matches either the
  # specified audince or nil. Then we ORDER BY audience, and then populate a hash with the
  # resulting objects. The nil-audience objects get populated in the Hash first, followed
  # by the audience-scoped one, so the resultant Hash always returns the most scoped
  # HelpText object.
  def self.for_object_class(object_class, audience = nil)
    Hash[HelpText
      .where(object_class: object_class.to_s, audience: [nil, audience.to_s])
      .order(:audience)
      .map{ |ht| [ht.attribute_name.to_s, ht] }]
    end

end
