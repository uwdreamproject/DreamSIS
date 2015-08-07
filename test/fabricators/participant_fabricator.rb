Fabricator(:participant) do
  Faker::Config.locale = 'en-US'

  # Basic Info
  firstname           { Faker::Name.first_name }
  lastname            { Faker::Name.last_name }
  nickname            { Faker::Name.first_name if rand() > 0.95 }
  street              { Faker::Address.street_address }
  city                { Faker::Address.city }
  state               { Faker::Address.state }
  zip                 { Faker::Address.zip_code }
  email               { |attrs| Faker::Internet.email(attrs[:firstname]) }
  phone_home          { Faker::PhoneNumber.phone_number }
  phone_mobile        { Faker::PhoneNumber.cell_phone }
  grad_year           { (2011..Time.now.year+8).step.sample }
  birthdate           { |attrs| Faker::Date.between( Date.new(attrs[:grad_year]-19, 1, 1), Date.new(attrs[:grad_year]-17, 12, 31) ) }
  sex                 { %w(M F).sample }
  free_reduced_lunch  { rand() > 0.35 }
  gpa                 { (2.00..3.99).step(0.01).sample}
  high_school_id      { HighSchool.partners.pluck(:id).sample }
  inactive            { rand() > 0.85 }

  # Race/Ethnicity
  # hispanic
  # african_american
  # american_indian
  # asian_american
  # pacific_islander
  # caucasian
  # african
  # latino
  # middle_eastern
  # other_ethnicity
  # african_american_heritage
  # african_heritage
  # american_indian_heritage
  # asian_american_heritage
  # hispanic_heritage
  # latino_heritage
  # middle_eastern_heritage
  # pacific_islander_heritage
  # caucasian_heritage
  # asian
  # asian_heritage
  # other_heritage
  # ethnicity_details
  
  # College Info
  # college_attending_id
  # postsecondary_goal
  # college_bound_scholarship
  # personal_statement_status
  # resume_status
  # activity_log_status
  # postsecondary_plan

  # Associations - do these manually because of complex association structure
  # college_applications(rand: 10) { |attrs, i| Fabricate(:college_application, grad_year: attrs[:grad_year]) }
  # scholarship_applications(rand: 4)
  # test_scores(rand: 2)
  # notes(rand: 25)
  # parents(rand: 2)
  
end
