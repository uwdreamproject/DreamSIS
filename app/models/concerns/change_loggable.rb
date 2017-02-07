module ChangeLoggable
  extend ActiveSupport::Concern

  included do
    has_many :changelogs, as: :change_loggable, class_name: 'Change', foreign_key: "change_loggable_id"
    
    after_create_commit :log_create
    after_update_commit :log_update
    after_destroy_commit :log_destroy
  end

  def log_create
    log_change 'create', self.attributes
  end

  def log_update
    log_change 'update', self.changes
  end
  
  def log_destroy
    log_change 'delete', self.attributes
  end
  
  def log_change(action_type, my_changes)
    ChangeLogJob.perform_later(
      action_type,
      self.class.to_s,
      self.id,
      YAML::dump(my_changes),
      Thread.current['user'].try(:id),
      Apartment::Tenant.current
    )
  end

end
