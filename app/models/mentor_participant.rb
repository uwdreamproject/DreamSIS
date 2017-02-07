class MentorParticipant < ApplicationRecord

  belongs_to :mentor, touch: true
  belongs_to :participant, touch: true
  
  validates_presence_of :mentor_id, :participant_id
  validates_uniqueness_of :mentor_id, scope: [:participant_id, :deleted_at]

  default_scope { order("people.lastname, people.firstname").includes(:participant).where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  
  after_save :update_filter_cache
  after_destroy :update_filter_cache

  acts_as_taggable

  # Updates the participant filter cache
  def update_filter_cache
    participant.save
  end
  
  def destroy
    update_attribute :deleted_at, Time.now
  end
  
  def deleted?
    !deleted_at.nil?
  end
  
end
