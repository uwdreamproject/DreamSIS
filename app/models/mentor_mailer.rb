class MentorMailer < ActionMailer::Base

  ActionMailer::Base.default_url_options[:host] = "dreamsis.com"

  def driver(mentor, sent_at = Time.now)
    @mentor = mentor
    mail(
      :subject =>     "#{Customer.name_label} Driver Conduct Agreement",
      :to =>  "#{@mentor.try(:fullname)} <#{@mentor.email}>",
      :from =>        "do-not-reply@dreamsis.com",
      :sent_on =>     sent_at
    )
  end
end
