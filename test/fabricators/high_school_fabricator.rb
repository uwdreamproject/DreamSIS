Fabricator(:high_school) do
  name                { Faker::Name.last_name + " High School" }
  street              { Faker::Address.street_address }
  city                { Faker::Address.city }
  state               { Faker::Address.state }
  zip                 { Faker::Address.zip_code }
  partner_school      { rand() > 0.25 }
  district            { Faker::Address.city + ([" School District", " Public Schools"].sample) }
end
