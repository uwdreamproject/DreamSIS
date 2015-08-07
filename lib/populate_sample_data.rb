class PopulateSampleData
  
  # Generate everything
  def self.generate_all(participant_count = 10)
    PopulateSampleData.generate_global_objects
    participants = []
    participant_count.times.map { participants << Fabricate(:participant) }
    PopulateSampleData.populate_participant_associations(participants)
    participants
  end

  # Generate high schools, scholarships, etc.
  def self.generate_global_objects
    10.times.map { Fabricate :high_school } if HighSchool.count < 10
    50.times.map { Fabricate :scholarship } if Scholarship.count < 50
  end
  
  def self.populate_participant_associations(participants)
    for participant in participants
      rand(10).times.map { Fabricate :college_application, participant_id: participant.id, grad_year: participant.grad_year rescue true }
      rand(4).times.map { Fabricate :scholarship_application, participant_id: participant.id, grad_year: participant.grad_year rescue true }
    end
  end
  
end