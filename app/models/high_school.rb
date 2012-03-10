class HighSchool < Location

  default_scope :order => "name"

  named_scope :partners, :conditions => { :partner_school => true }

  has_many :participants do
    def in_participating_cohort(quarter)
      find_all_by_grad_year quarter.participating_cohort
    end
  end
  
  has_many :visits, :foreign_key => 'location_id' do
    def for(quarter)
      find_all {|visit| quarter.include?(visit.date)}
    end
  end

  has_many :mentor_quarter_groups , :foreign_key => 'location_id' do
    def for(quarter)
      find_all_by_quarter_id quarter.id
    end
  end
  
  # Returns an array of unique graudation years
  def cohorts
    participants.find(:all, :select => [:grad_year]).collect(&:grad_year).uniq.compact.sort.reverse
  end
  
end
