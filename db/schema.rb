# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140326192359) do

  create_table "activity_logs", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "mentor_id"
    t.integer  "direct_interaction_count"
    t.integer  "indirect_interaction_count"
    t.text     "student_time"
    t.text     "non_student_time"
    t.text     "highlight_note"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "changes", :force => true do |t|
    t.integer  "change_loggable_id"
    t.string   "change_loggable_type"
    t.text     "changes"
    t.integer  "user_id"
    t.string   "action_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "restored_at"
    t.integer  "restored_user_id"
  end

  add_index "changes", ["change_loggable_id", "change_loggable_type"], :name => "index_changes_on_changable"

  create_table "clearinghouse_requests", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "created_by"
    t.string   "submitted_filename"
    t.datetime "submitted_at"
    t.datetime "retrieved_at"
    t.text     "participant_ids"
    t.text     "ftp_password"
    t.integer  "number_of_records_submitted"
    t.integer  "number_of_records_returned"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "detail_report_filename"
  end

  create_table "college_applications", :force => true do |t|
    t.integer  "participant_id"
    t.integer  "institution_id"
    t.datetime "date_applied"
    t.datetime "date_notified"
    t.string   "decision"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "choice"
    t.boolean  "personal_statement_started"
    t.boolean  "personal_statement_completed"
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.integer  "program_id"
    t.integer  "parent_customer_id"
    t.boolean  "link_to_uw"
    t.string   "term_system"
    t.text     "risk_form_content"
    t.boolean  "require_background_checks"
    t.string   "mentor_label"
    t.string   "lead_label"
    t.string   "participant_label"
    t.string   "workbook_label"
    t.string   "intake_survey_label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mentee_label"
    t.boolean  "experimental"
    t.integer  "clearinghouse_customer_number"
    t.date     "clearinghouse_contract_start_date"
    t.integer  "clearinghouse_number_of_submissions_allowed"
    t.string   "url_shortcut"
    t.text     "allowable_login_methods"
    t.string   "visit_label"
    t.text     "college_application_choice_options",          :default => "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''Reach\nSolid\nSafety'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''"
    t.text     "paperwork_status_options"
    t.string   "not_target_label"
    t.text     "activity_log_student_time_categories"
    t.text     "activity_log_non_student_time_categories"
    t.text     "visit_attendance_options"
  end

  create_table "degrees", :force => true do |t|
    t.string   "type"
    t.integer  "participant_id"
    t.integer  "institution_id"
    t.integer  "high_school_id"
    t.date     "graduated_on"
    t.string   "degree_title"
    t.string   "major_1"
    t.string   "major_1_cip"
    t.string   "major_2"
    t.string   "major_2_cip"
    t.string   "major_3"
    t.string   "major_3_cip"
    t.string   "major_4"
    t.string   "major_4_cip"
    t.string   "source"
    t.integer  "clearinghouse_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "degrees", ["customer_id"], :name => "index_degrees_on_customer_id"

  create_table "education_levels", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "education_levels", ["customer_id"], :name => "index_education_levels_on_customer_id"

  create_table "enrollments", :force => true do |t|
    t.string   "type"
    t.integer  "participant_id"
    t.integer  "institution_id"
    t.integer  "high_school_id"
    t.date     "began_on"
    t.date     "ended_on"
    t.string   "enrollment_status"
    t.string   "class_level"
    t.string   "major_1"
    t.string   "major_1_cip"
    t.string   "major_2"
    t.string   "major_2_cip"
    t.string   "source"
    t.integer  "clearinghouse_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "enrollments", ["customer_id"], :name => "index_enrollments_on_customer_id"

  create_table "event_attendances", :force => true do |t|
    t.integer  "person_id"
    t.integer  "event_id"
    t.boolean  "rsvp"
    t.boolean  "attended"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_shift_id"
    t.boolean  "admin"
    t.integer  "customer_id"
    t.string   "attendance_option"
  end

  add_index "event_attendances", ["customer_id"], :name => "index_event_attendances_on_customer_id"

  create_table "event_groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_external_students"
    t.boolean  "allow_external_volunteers"
    t.integer  "volunteer_training_id"
    t.integer  "mentor_training_id"
    t.boolean  "volunteer_training_optional"
    t.boolean  "mentor_training_optional"
    t.string   "stylesheet_url"
    t.text     "student_description"
    t.text     "volunteer_description"
    t.text     "mentor_description"
    t.text     "footer_content"
    t.text     "student_confirmation_message"
    t.text     "volunteer_confirmation_message"
    t.text     "mentor_confirmation_message"
    t.boolean  "hide_description_in_confirmation_message"
    t.integer  "customer_id"
  end

  add_index "event_groups", ["customer_id"], :name => "index_event_groups_on_customer_id"

  create_table "event_shifts", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "event_id"
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "show_for_volunteers"
    t.boolean  "show_for_mentors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "event_shifts", ["customer_id"], :name => "index_event_shifts_on_customer_id"

  create_table "event_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "customer_id"
  end

  add_index "event_types", ["customer_id"], :name => "index_event_types_on_customer_id"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.time     "start_time"
    t.time     "end_time"
    t.integer  "location_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "show_for_participants", :default => true
    t.boolean  "show_for_mentors",      :default => true
    t.boolean  "allow_rsvps"
    t.integer  "event_type_id"
    t.integer  "event_group_id"
    t.string   "location_text"
    t.integer  "capacity"
    t.integer  "event_coordinator_id"
    t.boolean  "time_tba"
    t.text     "student_description"
    t.text     "volunteer_description"
    t.text     "mentor_description"
    t.integer  "student_capacity"
    t.integer  "mentor_capacity"
    t.integer  "volunteer_capacity"
    t.time     "student_start_time"
    t.time     "student_end_time"
    t.time     "volunteer_start_time"
    t.time     "volunteer_end_time"
    t.time     "mentor_start_time"
    t.time     "mentor_end_time"
    t.boolean  "show_for_students",     :default => true
    t.boolean  "show_for_volunteers",   :default => true
    t.integer  "customer_id"
  end

  add_index "events", ["customer_id"], :name => "index_events_on_customer_id"

  create_table "grade_levels", :force => true do |t|
    t.string   "title"
    t.integer  "level"
    t.string   "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "how_did_you_hear_options", :force => true do |t|
    t.string   "name"
    t.boolean  "show_for_participants"
    t.boolean  "show_for_mentors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "how_did_you_hear_options", ["customer_id"], :name => "index_how_did_you_hear_options_on_customer_id"

  create_table "how_did_you_hear_options_people", :id => false, :force => true do |t|
    t.integer "person_id"
    t.integer "how_did_you_hear_option_id"
    t.integer "customer_id"
  end

  add_index "how_did_you_hear_options_people", ["customer_id"], :name => "index_how_did_you_hear_options_people_on_customer_id"

  create_table "identities", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "identities", ["customer_id"], :name => "index_identities_on_customer_id"

  create_table "income_levels", :force => true do |t|
    t.float    "min_level"
    t.float    "max_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "income_levels", ["customer_id"], :name => "index_income_levels_on_customer_id"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "partner_school"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
    t.string   "county"
    t.string   "district"
    t.string   "school_code"
    t.integer  "institution_id"
    t.string   "country"
    t.string   "website_url"
    t.boolean  "enable_college_mapper_integration"
    t.integer  "customer_id"
  end

  add_index "locations", ["customer_id"], :name => "index_locations_on_customer_id"

  create_table "mentor_participants", :force => true do |t|
    t.integer  "mentor_id"
    t.integer  "participant_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "college_mapper_id"
  end

  create_table "mentor_term_groups", :force => true do |t|
    t.integer  "term_id"
    t.integer  "location_id"
    t.string   "title"
    t.string   "course_id"
    t.string   "times"
    t.time     "depart_time"
    t.time     "return_time"
    t.integer  "capacity"
    t.boolean  "none_option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mentor_terms_count", :default => 0
    t.integer  "linked_group_id"
    t.string   "day_of_week"
    t.integer  "customer_id"
    t.string   "permissions_level"
  end

  add_index "mentor_term_groups", ["customer_id"], :name => "index_mentor_term_groups_on_customer_id"

  create_table "mentor_terms", :force => true do |t|
    t.integer  "mentor_id"
    t.integer  "mentor_term_group_id"
    t.boolean  "lead"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "volunteer"
    t.boolean  "driver"
    t.text     "notes"
    t.integer  "customer_id"
  end

  add_index "mentor_terms", ["customer_id"], :name => "index_mentor_terms_on_customer_id"

  create_table "notes", :force => true do |t|
    t.text     "note"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "deleter_id"
    t.integer  "notable_id"
    t.string   "notable_type"
    t.string   "creator_name"
    t.string   "category"
    t.string   "access_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.datetime "document_updated_at"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.string   "document_file_name"
    t.string   "title"
  end

  add_index "notes", ["customer_id"], :name => "index_notes_on_customer_id"

  create_table "object_filters", :force => true do |t|
    t.string   "object_class"
    t.string   "title"
    t.text     "criteria"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "opposite_title"
    t.integer  "target_percentage"
    t.integer  "warning_threshold"
    t.date     "start_display_at"
    t.date     "end_display_at"
    t.integer  "earliest_grade_level"
    t.integer  "earliest_grade_level_level"
    t.integer  "latest_grade_level_level"
    t.integer  "customer_id"
  end

  add_index "object_filters", ["customer_id"], :name => "index_object_filters_on_customer_id"

  create_table "participant_groups", :force => true do |t|
    t.string   "title"
    t.integer  "grad_year"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participants_count", :default => 0
  end

  create_table "people", :force => true do |t|
    t.string   "firstname"
    t.string   "middlename"
    t.string   "lastname"
    t.string   "suffix"
    t.string   "nickname"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "email"
    t.string   "phone_home"
    t.string   "phone_mobile"
    t.string   "phone_work"
    t.string   "screen_name"
    t.string   "screen_name_type"
    t.date     "birthdate",                             :limit => 255
    t.string   "sex"
    t.boolean  "free_reduced_lunch"
    t.boolean  "no_internet_at_home"
    t.boolean  "english_not_primary_at_home"
    t.string   "other_languages"
    t.boolean  "english_second_language"
    t.integer  "grad_year"
    t.float    "gpa"
    t.date     "gpa_date"
    t.text     "after_school_activities"
    t.text     "time_conflicts"
    t.date     "fafsa_submitted_date"
    t.date     "binder_date"
    t.date     "photo_release_date"
    t.boolean  "photo_release_no_fullname"
    t.string   "relationship"
    t.string   "type"
    t.integer  "high_school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "first_generation"
    t.boolean  "computer_at_home"
    t.string   "dietary_restrictions"
    t.boolean  "vegetarian"
    t.boolean  "vegan"
    t.boolean  "hispanic"
    t.boolean  "african_american"
    t.boolean  "american_indian"
    t.boolean  "asian"
    t.boolean  "pacific_islander"
    t.boolean  "caucasian"
    t.string   "ethnicity_details"
    t.boolean  "inactive"
    t.integer  "mother_education_level_id"
    t.integer  "father_education_level_id"
    t.string   "mother_education_country"
    t.string   "father_education_country"
    t.integer  "family_income_level_id"
    t.integer  "college_attending_id"
    t.integer  "household_size"
    t.boolean  "single_parent_household"
    t.boolean  "not_attending_college"
    t.date     "intake_survey_date"
    t.boolean  "received_binder"
    t.boolean  "live_the_dream_recipient"
    t.boolean  "live_the_dream_nominee"
    t.boolean  "address_is_invalid"
    t.boolean  "email_is_invalid"
    t.text     "other_programs"
    t.date     "college_graduation_date"
    t.boolean  "target_participant"
    t.boolean  "not_target_participant"
    t.text     "inactive_explanation"
    t.datetime "inactive_date"
    t.string   "parent_only_speaks_language"
    t.boolean  "kosher"
    t.boolean  "halal"
    t.boolean  "foster_youth"
    t.string   "postsecondary_goal"
    t.boolean  "live_with_mother"
    t.boolean  "live_with_father"
    t.boolean  "parent_graduated_college"
    t.string   "family_members_who_went_to_college"
    t.boolean  "family_members_graduated"
    t.boolean  "attended_school_outside_usa"
    t.string   "countries_attended_school_outside_usa"
    t.boolean  "attended_grade_1_outside_usa"
    t.boolean  "attended_grade_2_outside_usa"
    t.boolean  "attended_grade_3_outside_usa"
    t.boolean  "attended_grade_4_outside_usa"
    t.boolean  "attended_grade_5_outside_usa"
    t.boolean  "attended_grade_6_outside_usa"
    t.boolean  "attended_grade_7_outside_usa"
    t.boolean  "attended_grade_8_outside_usa"
    t.boolean  "attended_grade_9_outside_usa"
    t.boolean  "attended_grade_10_outside_usa"
    t.boolean  "attended_grade_11_outside_usa"
    t.boolean  "attended_grade_12_outside_usa"
    t.boolean  "african"
    t.boolean  "latino"
    t.boolean  "middle_eastern"
    t.boolean  "other_ethnicity"
    t.string   "african_american_heritage"
    t.string   "african_heritage"
    t.string   "american_indian_heritage"
    t.string   "asian_heritage"
    t.string   "hispanic_heritage"
    t.string   "latino_heritage"
    t.string   "middle_eastern_heritage"
    t.string   "pacific_islander_heritage"
    t.string   "caucasian_heritage"
    t.string   "other_heritage"
    t.boolean  "bad_address"
    t.boolean  "bad_phone"
    t.boolean  "bad_email"
    t.integer  "previous_participant_id"
    t.datetime "ferpa_agreement_signed_at"
    t.datetime "background_check_run_at"
    t.string   "background_check_result"
    t.datetime "risk_form_signed_at"
    t.string   "risk_form_signature"
    t.string   "reg_id"
    t.string   "uw_student_no"
    t.string   "uw_net_id"
    t.datetime "resource_cache_updated_at"
    t.string   "display_name"
    t.string   "survey_id"
    t.string   "other_how_did_you_hear"
    t.boolean  "can_send_texts"
    t.boolean  "can_receive_texts"
    t.boolean  "unlimited_texting"
    t.boolean  "college_bound_scholarship"
    t.string   "other_college_programs"
    t.integer  "mentor_participant_count"
    t.integer  "other_location_id"
    t.text     "aliases"
    t.boolean  "crimes_against_persons_or_financial"
    t.boolean  "drug_related_crimes"
    t.boolean  "related_proceedings_crimes"
    t.boolean  "medicare_healthcare_crimes"
    t.text     "victim_crimes_explanation"
    t.boolean  "general_convictions"
    t.text     "general_convictions_explanation"
    t.datetime "background_check_authorized_at"
    t.datetime "van_driver_training_completed_at"
    t.string   "husky_card_rfid"
    t.integer  "participant_group_id"
    t.string   "avatar_image_url"
    t.string   "organization"
    t.string   "shirt_size"
    t.integer  "college_mapper_id"
    t.boolean  "fafsa_not_applicable"
    t.integer  "child_id"
    t.string   "relationship_to_child"
    t.string   "occupation"
    t.decimal  "annual_income"
    t.boolean  "needs_interpreter"
    t.text     "meeting_availability"
    t.string   "preferred_contact_method"
    t.string   "preferred_phone"
    t.string   "facebook_id"
    t.boolean  "check_email_regularly"
    t.integer  "student_id_number"
    t.string   "birthplace"
    t.boolean  "married"
    t.integer  "number_of_children"
    t.boolean  "free_reduced_lunch_signed_up"
    t.string   "parent_type"
    t.text     "filter_cache"
    t.string   "login_token"
    t.datetime "login_token_expires_at"
    t.integer  "customer_id"
    t.string   "email2"
    t.boolean  "gluten_free"
    t.boolean  "deceased"
    t.boolean  "incarcerated"
    t.integer  "highest_education_level_id"
    t.string   "migration_id"
    t.boolean  "lives_with"
    t.string   "education_country"
    t.string   "personal_statement_status"
    t.string   "resume_status"
    t.string   "activity_log_status"
    t.string   "avatar"
    t.string   "postsecondary_plan"
  end

  add_index "people", ["college_attending_id"], :name => "index_people_on_college_attending_id"
  add_index "people", ["customer_id"], :name => "index_people_on_customer_id"
  add_index "people", ["display_name"], :name => "index_people_on_display_name"
  add_index "people", ["firstname"], :name => "index_people_on_firstname"
  add_index "people", ["grad_year"], :name => "index_people_on_grad_year"
  add_index "people", ["lastname"], :name => "index_people_on_lastname"
  add_index "people", ["uw_net_id"], :name => "index_people_on_uw_net_id"

  create_table "people_programs", :id => false, :force => true do |t|
    t.integer  "person_id"
    t.integer  "program_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people_programs", ["person_id", "program_id"], :name => "index_people_programs_on_person_id_and_program_id"

  create_table "programs", :force => true do |t|
    t.string   "title"
    t.string   "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "website_url"
  end

  create_table "scholarship_applications", :force => true do |t|
    t.integer  "scholarship_id"
    t.integer  "participant_id"
    t.boolean  "awarded"
    t.boolean  "renewable"
    t.boolean  "accepted"
    t.decimal  "amount"
    t.date     "date_applied"
    t.text     "restrictions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.boolean  "nominated"
    t.integer  "renewable_years"
    t.boolean  "full_ride"
    t.boolean  "gap_funding"
    t.boolean  "living_stipend"
    t.integer  "institution_id"
    t.date     "application_due_date"
  end

  create_table "scholarships", :force => true do |t|
    t.string   "title"
    t.string   "organization_name"
    t.text     "description"
    t.decimal  "default_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.integer  "default_renewable_years"
    t.boolean  "default_full_ride"
    t.boolean  "default_gap_funding"
    t.boolean  "default_living_stipend"
    t.boolean  "default_renewable"
  end

  add_index "scholarships", ["customer_id"], :name => "index_scholarships_on_customer_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "terms", :force => true do |t|
    t.integer  "year"
    t.integer  "quarter_code"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "course_ids"
    t.boolean  "allow_signups"
    t.string   "title"
    t.string   "type"
    t.integer  "customer_id"
  end

  add_index "terms", ["customer_id"], :name => "index_terms_on_customer_id"

  create_table "test_scores", :force => true do |t|
    t.integer  "participant_id"
    t.integer  "test_type_id"
    t.datetime "registered_at"
    t.datetime "taken_at"
    t.decimal  "total_score"
    t.text     "section_scores"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.boolean  "passed"
  end

  add_index "test_scores", ["customer_id"], :name => "index_test_scores_on_customer_id"

  create_table "test_types", :force => true do |t|
    t.string   "name"
    t.decimal  "maximum_total_score"
    t.text     "sections"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.string   "score_calculation_method"
    t.boolean  "passable"
  end

  add_index "test_types", ["customer_id"], :name => "index_test_types_on_customer_id"

  create_table "training_completions", :force => true do |t|
    t.integer  "training_id"
    t.integer  "person_id"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "training_completions", ["customer_id"], :name => "index_training_completions_on_customer_id"

  create_table "trainings", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "video_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chapters_url"
    t.string   "stylesheet_url"
    t.integer  "customer_id"
  end

  add_index "trainings", ["customer_id"], :name => "index_trainings_on_customer_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "remember_token"
    t.string   "remember_token_expires_at"
    t.string   "identity_url"
    t.string   "type"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.string   "provider"
    t.string   "uid"
    t.integer  "customer_id"
  end

  add_index "users", ["customer_id"], :name => "index_users_on_customer_id"

end
