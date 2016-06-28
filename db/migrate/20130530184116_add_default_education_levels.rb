class AddDefaultEducationLevels < ActiveRecord::Migration
  def self.up
    EducationLevel.create(sequence: 1, title: "No high school")
    EducationLevel.create(sequence: 2, title: "Some high school, no diploma")
    EducationLevel.create(sequence: 3, title: "High school graduate/GED")
    EducationLevel.create(sequence: 4, title: "Some college, no degree")
    EducationLevel.create(sequence: 5, title: "2-year college degree")
    EducationLevel.create(sequence: 6, title: "4-year college degree")
    EducationLevel.create(sequence: 7, title: "Postgraduate study")
  end

  def self.down
    EducationLevel.find(:first, conditions: { sequence: 7, title: "Postgraduate study" }).destroy
    EducationLevel.find(:first, conditions: { sequence: 6, title: "4-year college degree" }).destroy
    EducationLevel.find(:first, conditions: { sequence: 5, title: "2-year college degree" }).destroy
    EducationLevel.find(:first, conditions: { sequence: 4, title: "Some college, no degree" }).destroy
    EducationLevel.find(:first, conditions: { sequence: 3, title: "High school graduate/GED" }).destroy
    EducationLevel.find(:first, conditions: { sequence: 2, title: "Some high school, no diploma" }).destroy
    EducationLevel.find(:first, conditions: { sequence: 1, title: "No high school" }).destroy
  end
end