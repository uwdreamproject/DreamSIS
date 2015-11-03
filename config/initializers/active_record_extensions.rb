module ActiveRecordTitle
  def to_title
    return title if respond_to?(:title)
    return name if respond_to?(:name)
    nil
  end
end

module ChangeLogged
  def self.append_features(base_class)
    base_class.has_many :changelogs, :as => :change_loggable, :class_name => 'Change', :foreign_key => "change_loggable_id"
    base_class.after_create { |record| Change.log_create(record) }
    base_class.after_update { |record| Change.log_update(record) }
    base_class.after_destroy { |record| Change.log_delete(record) }
  end
end

module Unpaginate
  def unpaginate
    self.limit(100000).offset(0)
  end
end

# include the extensions
ActiveRecord::Base.send(:include, ActiveRecordTitle)
ActiveRecord::Base.send(:include, ChangeLogged)
::ActiveRecord::Relation.send(:include, Unpaginate)