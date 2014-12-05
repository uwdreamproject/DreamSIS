class MentorMailer < ActionMailer::Base

  ActionMailer::Base.default_url_options[:host] = "dreamsis.com"

  def driver(mentor, sent_at = Time.now)
    css :email

    @mentor = mentor
    subject     "#{Customer.name_label} Driver Conduct Agreement"
    recipients  "#{@mentor.try(:fullname)} <#{@mentor.email}>"
    from        "do-not-reply@dreamsis.com"
    sent_on     sent_at
  end
end