module MentorsHelper
  BACKGROUND_CHECK_COUNT = 10
  SEX_OFFENDER_CHECK_COUNT = 5

  def background_check_textblock(mentors)
    raise "No mentors given" if mentors.nil?
    blocks = []
    mentors.each do |mentor|
      if mentor.background_check_result.blank? && mentor.background_check_authorized
        fname = mentor.try(:firstname).split()
        blocks << [fname[0].to_s.gsub("-",""), fname[1].to_s[0], mentor.try(:lastname), mentor.try(:sex), mentor.try(:birthdate).try(:to_s, :short_date)].join("|")
      end
      break if blocks.count >= BACKGROUND_CHECK_COUNT
    end
    blocks.join("\n")
  end

  def sex_offender_check_textblock(mentors)
    raise "No mentors given" if mentors.nil?
    blocks = []
    mentors.each do |mentor|
      if mentor.sex_offender_check_result.blank? && mentor.background_check_authorized
        fname = mentor.try(:firstname).split()
        (0..fname.count-1).each do |i|
          blocks << [fname[0..i].join(" "), mentor.try(:lastname)].join("|")
        end
        aliases = mentor.try(:aliases)
        if aliases && !aliases.try(:first).blank?
          aliases.lines.each do |line|
            names =  line.split(" ")
            last = names[names.count - 1]
            if names.count > 1
              (0..names.count-2).each do |i|
                blocks << [names[0..i].join(" "), last].join("|")
              end
            else
              blocks << names.first
            end
          end
        end
      end
      break if blocks.count >= SEX_OFFENDER_CHECK_COUNT
    end
    blocks.join("\n")
  end
end

