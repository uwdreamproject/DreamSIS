class CreateTrainings < ActiveRecord::Migration
  def self.up
    create_table :trainings do |t|
      t.string :title
      t.text :description
      t.string :video_url
      t.text :chapters

      t.timestamps
    end
  end

  def self.down
    drop_table :trainings
  end
end
