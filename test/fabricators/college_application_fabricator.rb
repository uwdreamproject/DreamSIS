Fabricator(:college_application) do
  transient grad_year: Time.now.year
  participant_id  nil
  institution_id  { Institution.pluck(:unitid).sample }
  choice          { %w[Reach Solid Safety].sample }
  date_applied    { |attrs| Faker::Date.between( Date.new(attrs[:grad_year]-1, 9, 1), Date.new(attrs[:grad_year], 6, 30) ) if attrs[:grad_year] <= Time.now.year && rand > 0.3 }
  decision        { |attrs| ["Accepted", "Denied", "Waitlisted", "Deferred", "No Longer Applying"].sample if attrs[:date_applied]}
end
