Fabricator(:scholarship_application) do
  transient grad_year: Time.now.year
  participant_id  nil
  scholarship_id  { Scholarship.pluck(:id).sample }
  date_applied    { |attrs| Faker::Date.between( Date.new(attrs[:grad_year]-1, 9, 1), Date.new(attrs[:grad_year], 6, 30) ) if attrs[:grad_year] <= Time.now.year && rand > 0.3 }
  application_due_date  { |attrs| Faker::Date.between( Date.new(attrs[:grad_year], 3, 1), Date.new(attrs[:grad_year], 6, 30) ) }
  awarded         { |attrs| rand > 0.7 if attrs[:date_applied] }
  renewable       { |attrs| rand > 0.7 if attrs[:awarded] }
  accepted        { |attrs| rand > 0.1 if attrs[:awarded] }
  amount          { (1000..40000).step(250).sample }
end
