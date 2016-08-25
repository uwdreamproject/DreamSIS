module ChangesHelper
  
  def prep_change_value(val)
    if val.nil? || val.blank?
      s = "nothing"
      t = "nil"
    elsif val.is_a?(String)
      s = "&ldquo;".html_safe + h(val) + "&rdquo;".html_safe
      t = "string"
    elsif val.is_a?(Numeric)
      s = val.to_s
      t = "number"
    elsif val.is_a?(Date)
      s = val.to_s(:long)
      t = "date"
    elsif val.is_a?(TrueClass) || val.is_a?(FalseClass)
      s = val.to_s
      t = "boolean"
    else
      s = "&ldquo;".html_safe + h(val.to_s) + "&rdquo;".html_safe
      t = ""
    end
    
    return content_tag(:code, s, class: "change_value #{t}")
  end
  
  def child_object_link(object, change)
    anchor_targets = {
      "CollegeApplication" => "college_applications",
      "ScholarshipApplication" => "scholarship_applications",
      "Parent" => "parents",
      "TestScore" => "test_scores",
      "CollegeEnrollment" => "college_enrollments",
      "CollegeDegree" => "college_degrees",
      "ParticipantMentor" => "mentors",
      "EventAttendance" => "events",
      "Document" => "documents",
      "Note" => "notes"
    }
    return change.change_loggable_type.to_s if !object.is_a?(Participant) || anchor_targets[change.change_loggable_type.to_s].nil?
    anchor = "!/section/#{anchor_targets[change.change_loggable_type]}"
		link_to change.change_loggable_type.to_s, participant_path(@object, anchor: anchor)
  end
  
end