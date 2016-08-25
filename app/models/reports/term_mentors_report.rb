class TermMentorsReport < Report

  def model_name
    Mentor
  end

  # Generate the file ready for sending to the user and change status to "generated".
  def xlsx_package
      term_id = key.scan(/\d+/).last
      term = Term.find term_id
      object_class.to_xlsx(data: objects, columns: Mentor.term_report_columns(term.to_param))
  end

end
