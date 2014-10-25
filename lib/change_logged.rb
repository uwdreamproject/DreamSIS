module ChangeLogged
  def self.append_features(base_class)
    base_class.has_many :changelogs, :as => :change_loggable, :class_name => 'Change'
    base_class.after_create { |record| Change.log_create(record) }
    base_class.after_update { |record| Change.log_update(record) }
    base_class.after_destroy { |record| Change.log_delete(record) }
  end
end

# include the extension 
#ActiveRecord::Base.send(:include, ChangeLogged)
