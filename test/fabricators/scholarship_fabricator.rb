Fabricator(:scholarship) do
  title {  
    [%w[Washington Community University MLK International College 4H Rotary Future].sample,
    %w[Leadership Service Diversity Multicultural Essay Opportunity Athletic].sample,
    %w[Award Scholarship Program Scholars Scholarship].sample].join(" ")
  }
  default_amount { (1000..40000).step(250).sample }
  organization_name { [Faker::Company.name, Faker::Company.suffix].join(" ") }
end