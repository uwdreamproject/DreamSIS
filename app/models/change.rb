# Keeps track of changes made to associated models.
class Change < ActiveRecord::Base
  belongs_to :change_loggable, polymorphic: true
  serialize :changes
  
  belongs_to :user
  belongs_to :restored_user, class_name: "User", foreign_key: "restored_user_id"
  
  NON_TRACKED_ATTRIBUTES = %w(created_at updated_at deleted_at creator_id updater_id deleter_id resource_cache_updated_at filter_cache)
  
  scope :for, ->(klasses) { where self.conditions_for(klasses) }
  scope :last50, -> { order("created_at DESC").limit(50) }
  scope :since, ->(time_ago) { where ['created_at > ?', time_ago] }

  default_scope { order("created_at DESC") }

  # Override this method so that we can use the reserved attribute name +changes+.
  # Since a Change object is never updated like a typical record (and therefore reliant
  # on the ActiveModel::Dirty methods), this is OK in this case.
  def self.dangerous_attribute_method?(name)
    name.to_s == 'changes' ? false : super(name)
  end

  # Gets called after_create
  def self.log_create(obj)
    return false if obj.is_a?(Change)
    return false if obj.is_a?(ActiveRecord::SessionStore::Session)
    Change.create(
      change_loggable_id: obj.id,
      change_loggable_type: obj.class.to_s,
      action_type: 'create',
      user_id: Thread.current['user'].try(:id),
      changes: cleanup_changes(obj.changes)
    )
  end
  
  # Gets called after_update
  def self.log_update(obj)
    return false if obj.is_a?(Change)
    return false if obj.is_a?(ActiveRecord::SessionStore::Session)
    my_changes = cleanup_changes(obj.changes)
    Change.create(
      change_loggable_id: obj.id,
      change_loggable_type: obj.class.to_s,
      action_type: 'update',
      user_id: Thread.current['user'].try(:id),
      changes: my_changes
    ) unless my_changes.empty?
  end
  
  # Gets called after_delete. Saves the final state of the object's attributes in the +changes+ attribute for easy restoration.
  def self.log_delete(obj)
    return false if obj.is_a?(Change)
    return false if obj.is_a?(ActiveRecord::SessionStore::Session)
    # if obj.class.respond_to?(:deleted_class)
    c = Change.create(
      change_loggable_id: obj.id,
      change_loggable_type: obj.class.to_s,
      action_type: 'delete',
      user_id: Thread.current['user'].try(:id),
      changes: obj.attributes
    )
      # c.update_attribute(:change_loggable_type, obj.class.deleted_class.to_s)
    # end
  end
  
  # Restores this object by creating a new matching object with the same attributes.
  def undelete!
    new_type = changes.delete("type")
    new_id = changes.delete("id")
    new_object = change_loggable_type.constantize.new(changes)
    new_object.update_attribute(:id, new_id)
    if new_object.valid?
      new_object.save!
      self.restored_at = Time.now
      self.restored_user_id = Thread.current['user'].try(:id)
      self.save!
    end
    new_object
  end
  
  def restored?
    !restored_at.nil?
  end

  # Returns the "identifier_string" for the associated changed object. ChangeLoggable models should include an +identifier_string+
  # method to assist with this.
  def identifier_string
    change_loggable.identifier_string rescue "unknown"
  end

  # Finds Changes that have occurred for the specified class, as well as for the deleted version of the class (if it exists)
  def self.for_class(*klass)
    results = []
    klass.each do |k|
      results << self.find_all_by_change_loggable_type(k.to_s)
      results << self.find_all_by_change_loggable_type(k.deleted_class.to_s) if k.respond_to?(:deleted_class)
    end
    results.flatten.uniq
  end
  
  protected
  
  # Cleans up the object's @changes hash so that we don't bother storing changes to things like +updated_at+ and +creator_id+
  def self.cleanup_changes(h)
    results = h.reject{|key,val| NON_TRACKED_ATTRIBUTES.include?(key)}
    logger.debug { "Cleanup Changes: \nBefore:\n" + h.to_yaml + "\nAfter:\n" + results.to_yaml }
    return results
  end
  
  # Used in the +for+ scope. Generates a valid array for use as a SQL :conditions paramater. Can accept an array of
  # Class names or a single Class name, and will automatically include the class's deleted_class equivalent if the model
  # is setup to use acts_as_soft_deletable (this way we can retrieve changes from the changelog that include deleted records).
  def self.conditions_for(klasses)
    klasses = [klasses] unless klasses.is_a?(Array)
    first = true; str = ""; params = []
    klasses.each do |k|
      str << ' OR ' unless first; first = false
      str << ' change_loggable_type = ? '
      str << ' OR change_loggable_type = ? ' if k.respond_to?(:deleted_class)
      params << k.to_s
      params << k.deleted_class.to_s if k.respond_to?(:deleted_class)
    end
    conditions = [str, params].flatten
  end
  
end
