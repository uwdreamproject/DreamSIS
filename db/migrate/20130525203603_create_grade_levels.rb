class CreateGradeLevels < ActiveRecord::Migration
  def self.up
    create_table :grade_levels, force: true do |t|
      t.string :title
      t.integer :level
      t.string :abbreviation
      t.timestamps
    end
    
    GradeLevel.create(level: 9, title: "9th Grade")
    GradeLevel.create(level: 10, title: "10th Grade")
    GradeLevel.create(level: 11, title: "11th Grade")
    GradeLevel.create(level: 12, title: "12th Grade")
    GradeLevel.create(level: 13, title: "College Freshman", abbreviation: "F")
    GradeLevel.create(level: 14, title: "College Sophomore", abbreviation: "S")
    GradeLevel.create(level: 15, title: "College Junior", abbreviation: "J")
    GradeLevel.create(level: 16, title: "College Senior", abbreviation: "R")
    GradeLevel.create(level: 17, title: "College 5th-Year")
  end

  def self.down
    drop_table :grade_levels
  end
end
