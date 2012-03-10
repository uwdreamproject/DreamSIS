class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :firstname
      t.string :middlename
      t.string :lastname
      t.string :suffix
      t.string :nickname
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :email
      t.string :phone_home
      t.string :phone_mobile
      t.string :phone_work
      t.string :screen_name
      t.string :screen_name_type
      t.string :birthdate
      t.string :sex
      t.boolean :free_reduced_lunch
      t.boolean :no_internet_at_home
      t.boolean :english_primary_at_home
      t.string :other_languages
      t.boolean :english_second_language
      t.integer :grad_year
      t.float :gpa
      t.date :gpa_date
      t.text :after_school_activities
      t.text :time_conflicts
      t.date :fafsa_submitted_date
      t.date :binder_date
      t.date :photo_release_date
      t.boolean :photo_release_no_fullname
      t.string :relationship
      t.string :type
      t.integer :high_school_id

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
