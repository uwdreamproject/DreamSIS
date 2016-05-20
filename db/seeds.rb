# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Education Levels
EducationLevel.create "title" => "No high school", "sequence" => 1
EducationLevel.create "title" => "Some high school, no diploma", "sequence" => 2
EducationLevel.create "title" => "High school graduate/GED", "sequence" => 3
EducationLevel.create "title" => "Some college, no degree", "sequence" => 4
EducationLevel.create "title" => "Technical certificate", "sequence" => 5
EducationLevel.create "title" => "2-year college degree", "sequence" => 6
EducationLevel.create "title" => "4-year college degree", "sequence" => 7
EducationLevel.create "title" => "Postgraduate study", "sequence" => 8

# Grade Levels
GradeLevel.create "title" => "9th Grade", "level" => 9
GradeLevel.create "title" => "10th Grade", "level" => 10
GradeLevel.create "title" => "11th Grade","level" => 11
GradeLevel.create "title" => "12th Grade", "level" => 12
GradeLevel.create "title" => "College Freshman", "level" => 13, "abbreviation" => "F"
GradeLevel.create "title" => "College Sophomore", "level" => 14, "abbreviation" => "S"
GradeLevel.create "title" => "College Junior", "level" => 15, "abbreviation" => "J"
GradeLevel.create "title" => "College Senior", "level" => 16, "abbreviation" => "R"
GradeLevel.create "title" => "College 5th-Year", "level" => 17

# Help Texts
HelpText.create({
  "object_class" => "Participant", 
  "attribute_name" => "household_size",
  "hint" => "Include yourself in this count.",
  "audience" => "Participant"
})
HelpText.create({
  "object_class" => "Participant", 
  "attribute_name" => "household_size",
  "hint" => "Include the student in this count.",
  "audience" => "Mentor"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "immigrant",
  "title" => "Do you identify yourself as an immigrant to the United States?",
  "audience" => "Participant"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "immigrant",
  "title" => "Identifies as an immigrant to the United States",
  "audience" => "Mentor"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "first_generation",
  "title" => "Does one or more of your parents/legal guardians hold a bachelor’s/4 year degree?",
  "audience" => "Participant"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "first_generation",
  "title" => "Did parents graduate from college?",
  "audience" => "Mentor"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "homeless",
  "title" => "I am currently experiencing unstable housing",
  "audience" => "Participant",
  "hint" => "I live with family members other than my parents/legal guardians, couch surfing, live with friends, homeless, live in a motel or hotel."
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "homeless",
  "title" => "Student is homeless",
  "audience" => "Mentor"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "subsidized_housing",
  "title" => "My family receives public assistance or lives in federally subsidized housing",
  "audience" => "Participant"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "subsidized_housing",
  "title" => "Family receives public assistance or lives in federally subsidized housing",
  "audience" => "Mentor"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "grad_year",
  "hint" => "Enter your expected graduation year.",
  "audience" => "Participant"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "grad_year",
  "hint" => "Enter the student's expected graduation year.",
  "audience" => "Mentor"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "college_bound_scholarship",
  "title" => "I'm signed up for Washington College Bound Scholarship",
  "audience" => "Participant"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "college_bound_scholarship",
  "title" => "Signed up for Washington College Bound Scholarship",
  "audience" => "Mentor"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "postsecondary_goal",
  "hint" => "What's your hope to do after graduating high school?",
  "audience" => "Participant"
})
HelpText.create({
  "object_class" => "Participant",
  "attribute_name" => "postsecondary_goal",
  "hint" => "What is the student's hope to do after graduating high school?",
  "audience" => "Mentor"
})

# Test Types
TestType.create({
  "name"                     => "ACT",
  "maximum_total_score"      => 36,
  "sections"                 => "English: 36\r\nMathematics: 36\r\nReading: 36\r\nScience: 36",
  "score_calculation_method" => "rounded-average",
  "passable"                 => false
})
TestType.create( {
  "name"                     => "ACT Writing (Subscore)",
  "maximum_total_score"      => 12,
  "sections"                 => "",
  "customer_id"              => 1,
  "score_calculation_method" => "sum",
  "passable"                 => false
})
TestType.create( {
  "name"                     => "PSAT",
  "maximum_total_score"      => 240,
  "sections"                 => "Critical Reading: 80\r\nMathematics: 80\r\nWriting: 80",
  "score_calculation_method" => nil,
  "passable"                 => false
})
TestType.create( {
  "name"                     => "SAT",
  "maximum_total_score"      => 2400,
  "sections"                 => "Critical Reading: 800\r\nMathematics: 800\r\nWriting: 800",
  "score_calculation_method" => nil,
  "passable"                 => false
})
TestType.create( {
  "name"                     => "COMPASS ESL",
  "maximum_total_score"      => 99,
  "sections"                 => "",
  "score_calculation_method" => "average",
  "passable"                 => true
})
TestType.create( {
  "name"                     => "COMPASS Mathematics",
  "maximum_total_score"      => 99,
  "sections"                 => "",
  "score_calculation_method" => "average",
  "passable"                 => true
})
TestType.create( {
  "name"                     => "COMPASS Reading",
  "maximum_total_score"      => 99,
  "sections"                 => "",
  "score_calculation_method" => "average",
  "passable"                 => true
})
TestType.create( {
  "name"                     => "COMPASS Writing Skills",
  "maximum_total_score"      => 99,
  "sections"                 => "",
  "score_calculation_method" => "average",
  "passable"                 => true
})


